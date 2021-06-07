module Radix exposing (..)

import Browser
import Browser.Navigation as Nav
import CAIP exposing (ChainIdCollection)
import ChainID exposing (ChainID)
import Contact exposing (Contact)
import Dict exposing (Dict)
import Page exposing (Page)
import RemoteData exposing (RemoteData(..))
import UUID
import Url exposing (Url)
import Webnative
import Webnative.Path as Path exposing (File, Path)



-- ⛩


type alias Flags =
    { seeds : List Int }



-- 🌳


type alias Model =
    { navKey : Nav.Key
    , page : Page
    , seeds : UUID.Seeds
    , url : Url
    , userData : UserData
    }



-- 🌳  ~  USER DATA


type alias UserData =
    { blockchainIds : RemoteData String ChainIdCollection
    , contacts : RemoteData String (List Contact)
    , name : Maybe String
    }



-- 🌳  ~  PERMISSIONS


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
        { directories = [ Path.directory [ "Documents", "Contacts" ] ]
        , files = []
        }
    }


permissions : Webnative.Permissions
permissions =
    { app = Just appPermissions
    , fs = Just fsPermissions
    }


contactsPath : Path File
contactsPath =
    Path.file [ "Documents", "Contacts", "Library.json" ]


blockchainsPath : Path File
blockchainsPath =
    Path.file [ "Documents", "Contacts", "Blockchain Networks.json" ]



-- 📣


type Msg
    = Bypassed
      -----------------------------------------
      -- 🐚
      -----------------------------------------
    | CopyToClipboard { notification : Maybe String, text : String }
    | GotWebnativeResponse Webnative.Response
    | SignIn
    | SignOut
      -----------------------------------------
      -- Contacts
      -----------------------------------------
    | AddNewContact Page.NewContext
    | GotUpdatedEditContext Page.EditContext
    | GotUpdatedIndexContext Page.IndexContext
    | GotUpdatedNewContext Page.NewContext
    | RemoveContact { index : Int }
    | UpdateContact Contact Page.EditContext
      -----------------------------------------
      -- Routing
      -----------------------------------------
    | UrlChanged Url
    | UrlRequested Browser.UrlRequest


type alias Manager =
    Model -> ( Model, Cmd Msg )
