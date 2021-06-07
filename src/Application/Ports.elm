port module Ports exposing (..)

import Webnative



-- 📣


port copyToClipboard : { notification : Maybe String, text : String } -> Cmd msg


port signOut : () -> Cmd msg


port webnativeRequest : Webnative.Request -> Cmd msg



-- 📰


port webnativeResponse : (Webnative.Response -> msg) -> Sub msg
