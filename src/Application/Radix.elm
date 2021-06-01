module Radix exposing (..)

import Browser
import Browser.Navigation as Nav
import Contact exposing (Contact)
import Page exposing (Page)
import RemoteData exposing (RemoteData(..))
import Url exposing (Url)
import Webnative
import Webnative.Path as Path exposing (File, Path)



-- ⛩


type alias Flags =
    {}



-- 🌳


type alias Model =
    { navKey : Nav.Key
    , page : Page
    , url : Url
    , userData : UserData
    }


type alias UserData =
    { contacts : RemoteData String (List Contact)
    , name : Maybe String
    }


appPermissions : Webnative.AppPermissions
appPermissions =
    { creator = "Fission", name = "Contacts" }


fsPermissions : Webnative.FileSystemPermissions
fsPermissions =
    { public =
        { directories = []
        , files = []
        }
    , private =
        { directories = []
        , files = [ contactsPath ]
        }
    }


permissions : Webnative.Permissions
permissions =
    { app = Just appPermissions
    , fs = Just fsPermissions
    }


contactsPath : Path File
contactsPath =
    Path.file [ "Documents", "Contacts", "Index.json" ]



-- 📣


type Msg
    = Bypassed
      -----------------------------------------
      -- 🐚
      -----------------------------------------
    | GotWebnativeResponse Webnative.Response
    | SignIn
      -----------------------------------------
      -- Contacts
      -----------------------------------------
    | AddNewContact Page.NewContext
    | GotUpdatedNewContext Page.NewContext
      -----------------------------------------
      -- Routing
      -----------------------------------------
    | UrlChanged Url
    | UrlRequested Browser.UrlRequest


type alias Manager =
    Model -> ( Model, Cmd Msg )
