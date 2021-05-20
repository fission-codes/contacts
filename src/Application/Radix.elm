module Radix exposing (..)

import Browser
import Browser.Navigation as Nav
import Page exposing (Page)
import Url exposing (Url)



-- 🌱


type alias Model =
    { navKey : Nav.Key
    , page : Page
    , url : Url
    }



-- 📣


type Msg
    = Bypassed
      -----------------------------------------
      -- Routing
      -----------------------------------------
    | UrlChanged Url
    | UrlRequested Browser.UrlRequest


type alias Manager =
    Model -> ( Model, Cmd Msg )
