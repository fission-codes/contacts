module State exposing (..)

import Browser.Navigation as Nav
import Page exposing (Page(..))
import Ports
import Radix exposing (..)
import RemoteData exposing (RemoteData(..))
import Return exposing (return)
import Routing
import Tag
import Url exposing (Url)
import Webnative exposing (Artifact(..), DecodedResponse(..), State(..))
import Wnfs



-- 🌱


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    Tuple.pair
        { page = Routing.fromUrl url
        , navKey = navKey
        , url = url
        , userData = Loading
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
                    -- TODO: Load data
                    { contacts = []
                    , name = username
                    }
                        |> Success
                        |> (\u -> { model | userData = u })
                        |> Return.singleton

                Nothing ->
                    Return.singleton { model | userData = NotAsked }

        Webnative (NoArtifact _) ->
            -- TODO
            Return.singleton model

        -----------------------------------------
        -- 💾
        -----------------------------------------
        Wnfs _ _ ->
            -- TODO
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



-- 🛠


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
