module State exposing (..)

import Browser.Navigation as Nav
import Contact
import Contacts.AddressType exposing (AddressType(..))
import Contacts.Wnfs
import Json.Decode as Decode
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



-- 🌱


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    Tuple.pair
        { page = Routing.fromUrl url
        , navKey = navKey
        , url = url
        , userData =
            { contacts = Loading
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
        GotWebnativeResponse a ->
            gotWebnativeResponse a

        SignIn ->
            signIn

        -----------------------------------------
        -- Contacts
        -----------------------------------------
        AddNewContact a ->
            addNewContact a

        GotUpdatedNewContext a ->
            gotUpdatedNewContext a

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


gotWebnativeResponse : Webnative.Response -> Manager
gotWebnativeResponse response model =
    case Webnative.decodeResponse Tag.fromString response of
        -----------------------------------------
        -- 🚀
        -----------------------------------------
        Webnative (Initialisation state) ->
            case usernameFromState state of
                Just username ->
                    { contacts = Loading
                    , name = Just username
                    }
                        |> (\u -> { model | userData = u })
                        |> Return.singleton
                        |> Return.command
                            (Ports.webnativeRequest Contacts.Wnfs.load)

                Nothing ->
                    { contacts = NotAsked
                    , name = Nothing
                    }
                        |> (\u -> { model | userData = u })
                        |> Return.singleton

        Webnative (Webnative.NoArtifact _) ->
            Return.singleton model

        -----------------------------------------
        -- 💾
        -----------------------------------------
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
            -- Wnfs.error err
            Return.singleton model


signIn : Manager
signIn model =
    permissions
        |> Webnative.redirectToLobby Webnative.CurrentUrl
        |> Ports.webnativeRequest
        |> return model



-- CONTACTS


addNewContact : Page.NewContext -> Manager
addNewContact context model =
    { address =
        { accountAddress = context.accountAddress
        , chainID = context.chainId
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


gotUpdatedNewContext : Page.NewContext -> Manager
gotUpdatedNewContext context model =
    case model.page of
        New _ ->
            Return.singleton { model | page = New context }

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
