module State exposing (..)

import Browser.Navigation as Nav
import CAIP
import ChainID
import Contact exposing (Contact)
import Contacts.AddressType exposing (AddressType(..))
import Contacts.Wnfs
import Dict
import Json.Decode as Decode
import List.Extra as List
import Maybe.Extra as Maybe
import Page exposing (Page(..))
import Ports
import Radix exposing (..)
import Random
import RemoteData exposing (RemoteData(..))
import Return exposing (return)
import Routing
import Tag exposing (Tag(..))
import UUID
import Url exposing (Url)
import Webnative exposing (Artifact(..), DecodedResponse(..), State(..))
import Wnfs exposing (Artifact(..))



-- 🌳


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    Tuple.pair
        { page = Routing.fromUrl url
        , navKey = navKey
        , seeds =
            case flags.seeds of
                [ a, b, c, d ] ->
                    { seed1 = Random.initialSeed a
                    , seed2 = Random.initialSeed b
                    , seed3 = Random.initialSeed c
                    , seed4 = Random.initialSeed d
                    }

                _ ->
                    { seed1 = Random.initialSeed 0
                    , seed2 = Random.initialSeed 0
                    , seed3 = Random.initialSeed 0
                    , seed4 = Random.initialSeed 0
                    }
        , url = url
        , userData =
            { blockchainIds = Loading
            , contacts = Loading
            , name = Nothing
            }
        }
        (permissions
            |> Webnative.init
            |> Ports.webnativeRequest
        )



-- 📣


update : Msg -> Radix.Manager
update msg =
    case msg of
        Bypassed ->
            Return.singleton

        -----------------------------------------
        -- 🐚
        -----------------------------------------
        CopyToClipboard a ->
            copyToClipboard a

        GotWebnativeResponse a ->
            gotWebnativeResponse a

        SignIn ->
            signIn

        SignOut ->
            signOut

        -----------------------------------------
        -- Contacts
        -----------------------------------------
        AddNewContact a ->
            addNewContact a

        GotUpdatedEditContext a ->
            gotUpdatedEditContext a

        GotUpdatedIndexContext a ->
            gotUpdatedIndexContext a

        GotUpdatedNewContext a ->
            gotUpdatedNewContext a

        RemoveContact a ->
            removeContact a

        UpdateContact a b ->
            updateContact a b

        -----------------------------------------
        -- Routing
        -----------------------------------------
        UrlChanged a ->
            Routing.urlChanged a

        UrlRequested a ->
            Routing.urlRequested a



-- 📰


subscriptions : Model -> Sub Msg
subscriptions _ =
    Ports.webnativeResponse GotWebnativeResponse



-- 🐚


copyToClipboard : { notification : Maybe String, text : String } -> Manager
copyToClipboard params model =
    params
        |> Ports.copyToClipboard
        |> return model


gotWebnativeResponse : Webnative.Response -> Manager
gotWebnativeResponse response model =
    case Webnative.decodeResponse Tag.fromString response of
        -----------------------------------------
        -- 🚀
        -----------------------------------------
        Webnative (Initialisation state) ->
            case usernameFromState state of
                Just username ->
                    { blockchainIds = Loading
                    , contacts = Loading
                    , name = Just username
                    }
                        |> (\u -> { model | userData = u })
                        |> Return.singleton
                        |> Return.command
                            (Ports.webnativeRequest Contacts.Wnfs.load)
                        |> Return.command
                            (Ports.webnativeRequest Contacts.Wnfs.loadBlockchains)

                Nothing ->
                    { blockchainIds = NotAsked
                    , contacts = NotAsked
                    , name = Nothing
                    }
                        |> (\u -> { model | userData = u })
                        |> Return.singleton

        Webnative (Webnative.NoArtifact _) ->
            Return.singleton model

        -----------------------------------------
        -- 💾
        -----------------------------------------
        Wnfs LoadedBlockchains (Utf8Content json) ->
            json
                |> Decode.decodeString (Decode.list ChainID.chainID)
                |> Result.map (List.sortBy .label)
                |> Result.map
                    (\list ->
                        { list = list
                        , groups = CAIP.chainIdsListToGroups list
                        }
                    )
                |> Result.withDefault CAIP.defaultChainIds
                |> (\dict ->
                        mapUserData
                            (\u -> { u | blockchainIds = Success dict })
                            model
                   )
                |> Return.singleton

        Wnfs LoadedContacts (Utf8Content json) ->
            json
                |> Decode.decodeString (Decode.list Contact.contact)
                |> Result.withDefault []
                |> (\c ->
                        mapUserData
                            (\u -> { u | contacts = Success c })
                            model
                   )
                |> Return.singleton

        Wnfs SavedBlockchains _ ->
            { tag = Tag.toString Untagged }
                |> Wnfs.publish
                |> Ports.webnativeRequest
                |> return model

        Wnfs SavedContacts _ ->
            { tag = Tag.toString Untagged }
                |> Wnfs.publish
                |> Ports.webnativeRequest
                |> return model

        Wnfs _ _ ->
            Return.singleton model

        -----------------------------------------
        -- 🥵
        -----------------------------------------
        -- Do something with the errors,
        -- here we cast them to strings
        -- TODO
        WebnativeError err ->
            -- Webnative.error err
            Return.singleton model

        WnfsError err ->
            case ( response.tag, err ) of
                ( "LoadedContacts", Wnfs.JavascriptError "Path does not exist" ) ->
                    model
                        |> mapUserData (\u -> { u | contacts = Success [] })
                        |> Return.singleton
                        |> Return.command
                            (Ports.webnativeRequest Contacts.Wnfs.init)

                ( "LoadedBlockchains", Wnfs.JavascriptError "Path does not exist" ) ->
                    model
                        |> mapUserData (\u -> { u | blockchainIds = Success CAIP.defaultChainIds })
                        |> Return.singleton
                        |> Return.command
                            (Ports.webnativeRequest Contacts.Wnfs.initBlockchains)

                _ ->
                    -- Wnfs.error err
                    Return.singleton model


signIn : Manager
signIn model =
    permissions
        |> Webnative.redirectToLobby Webnative.CurrentUrl
        |> Ports.webnativeRequest
        |> return model


signOut : Manager
signOut model =
    return model (Ports.signOut ())



-- CONTACTS


addNewContact : Page.NewContext -> Manager
addNewContact context model =
    let
        chainIds =
            RemoteData.withDefault
                CAIP.defaultChainIds
                model.userData.blockchainIds

        ( uuid, newSeeds ) =
            UUID.step model.seeds
    in
    { uuid = UUID.toString uuid

    --
    , address =
        { accountAddress = context.accountAddress
        , chainID =
            context.chainID
                |> Maybe.orElse
                    (chainIds.list
                        |> List.head
                        |> Maybe.map CAIP.chainIdToString
                    )
                |> Maybe.withDefault ""
        , addressType = Contacts.AddressType.toString BlockchainAddress
        }
    , createdAt = "TODO"
    , label = context.label
    , modifiedAt = "TODO"
    , notes =
        case String.trim context.notes of
            "" ->
                Nothing

            notes ->
                Just notes
    }
        |> List.singleton
        |> List.append (RemoteData.withDefault [] model.userData.contacts)
        |> (\c ->
                mapUserData (\u -> { u | contacts = Success c }) model
           )
        |> (\m ->
                { m | seeds = newSeeds }
           )
        |> Return.singleton
        |> Return.command
            (Nav.pushUrl model.navKey "../")
        |> Return.effect_
            (\newModel ->
                newModel.userData.contacts
                    |> RemoteData.withDefault []
                    |> Contacts.Wnfs.save
                    |> Ports.webnativeRequest
            )


gotUpdatedEditContext : Page.EditContext -> Manager
gotUpdatedEditContext context model =
    case model.page of
        Edit _ uid ->
            Return.singleton { model | page = Edit context uid }

        _ ->
            Return.singleton model


gotUpdatedIndexContext : Page.IndexContext -> Manager
gotUpdatedIndexContext context model =
    case model.page of
        Index _ ->
            Return.singleton { model | page = Index context }

        _ ->
            Return.singleton model


gotUpdatedNewContext : Page.NewContext -> Manager
gotUpdatedNewContext context model =
    case model.page of
        New _ ->
            Return.singleton { model | page = New context }

        _ ->
            Return.singleton model


removeContact : { index : Int } -> Manager
removeContact { index } model =
    case model.userData.contacts of
        Success list ->
            let
                newList =
                    List.removeAt index list
            in
            return
                (mapUserData (\u -> { u | contacts = Success newList }) model)
                (Ports.webnativeRequest <| Contacts.Wnfs.save newList)

        _ ->
            Return.singleton model


updateContact : Contact -> Page.EditContext -> Manager
updateContact contact context model =
    { contact
        | address =
            { accountAddress =
                Maybe.withDefault
                    contact.address.accountAddress
                    context.accountAddress
            , chainID =
                Maybe.withDefault
                    contact.address.chainID
                    context.chainID
            , addressType =
                Contacts.AddressType.toString BlockchainAddress
            }
        , label =
            Maybe.withDefault
                contact.label
                context.label
        , notes =
            case Maybe.map String.trim context.notes of
                Just "" ->
                    contact.notes

                Just notes ->
                    Just notes

                Nothing ->
                    contact.notes
    }
        |> (\a ->
                List.map
                    (\b ->
                        if a.uuid == b.uuid then
                            a

                        else
                            b
                    )
                    (RemoteData.withDefault [] model.userData.contacts)
           )
        |> (\c ->
                mapUserData (\u -> { u | contacts = Success c }) model
           )
        |> Return.singleton
        |> Return.command
            (Nav.pushUrl model.navKey "../../")
        |> Return.effect_
            (\newModel ->
                newModel.userData.contacts
                    |> RemoteData.withDefault []
                    |> Contacts.Wnfs.save
                    |> Ports.webnativeRequest
            )



-- 🛠


mapUserData : (UserData -> UserData) -> Model -> Model
mapUserData fn model =
    { model | userData = fn model.userData }


usernameFromState : Webnative.State -> Maybe String
usernameFromState state =
    case state of
        NotAuthorised ->
            Nothing

        AuthSucceeded { username } ->
            Just username

        AuthCancelled _ ->
            Nothing

        Continuation { username } ->
            Just username
