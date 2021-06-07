module State exposing (..)

import Browser.Navigation as Nav
import CAIP
import ChainID
import Contact
import Contacts.AddressType exposing (AddressType(..))
import Contacts.Wnfs
import Json.Decode as Decode
import List.Extra as List
import Maybe.Extra as Maybe
import Page exposing (Page(..))
import Ports
import Radix exposing (..)
import RemoteData exposing (RemoteData(..))
import Return exposing (return)
import Routing
import Tag exposing (Tag(..))
import Url exposing (Url)
import Webnative exposing (Artifact(..), DecodedResponse(..), State(..))
import Wnfs exposing (Artifact(..))



-- 🌳


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    Tuple.pair
        { page = Routing.fromUrl url
        , navKey = navKey
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

        GotUpdatedIndexContext a ->
            gotUpdatedIndexContext a

        GotUpdatedNewContext a ->
            gotUpdatedNewContext a

        RemoveContact a ->
            removeContact a

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
                |> Result.withDefault []
                |> (\c ->
                        mapUserData
                            (\u -> { u | blockchainIds = Success c })
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
    in
    { address =
        { accountAddress = context.accountAddress
        , chainID =
            context.chainID
                |> Maybe.orElse
                    (chainIds
                        |> List.head
                        |> Maybe.map CAIP.chainIdToString
                    )
                |> Maybe.withDefault ""
        , addressType = Contacts.AddressType.toString BlockchainAddress
        }
    , createdAt = ""
    , label = context.label
    , modifiedAt = ""
    , notes =
        case String.trim context.notes of
            "" ->
                Nothing

            notes ->
                Just notes
    }
        |> List.singleton
        |> List.append (RemoteData.withDefault [] model.userData.contacts)
        |> (\c -> mapUserData (\u -> { u | contacts = Success c }) model)
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
