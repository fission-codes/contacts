module Radix exposing (..)

import Browser
import Browser.Navigation as Nav
import Page exposing (Page)
import RemoteData exposing (RemoteData(..))
import Url exposing (Url)
import Webnative



-- ⛩


type alias Flags =
    {}



-- 🌱


type alias Model =
    { navKey : Nav.Key
    , page : Page
    , url : Url
    , userData : RemoteData String UserData
    }


type alias UserData =
    {}


appPermissions : Webnative.AppPermissions
appPermissions =
    { creator = "Fission", name = "Contacts" }


permissions : Webnative.Permissions
permissions =
    { app = Just appPermissions, fs = Nothing }



-- 📣


type Msg
    = Bypassed
      -----------------------------------------
      -- 🐚
      -----------------------------------------
    | GotWebnativeResponse Webnative.Response
    | SignIn
      -----------------------------------------
      -- Routing
      -----------------------------------------
    | UrlChanged Url
    | UrlRequested Browser.UrlRequest


type alias Manager =
    Model -> ( Model, Cmd Msg )
