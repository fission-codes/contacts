port module Ports exposing (..)

import Webnative



-- 📣


port copyToClipboard : String -> Cmd msg


port webnativeRequest : Webnative.Request -> Cmd msg



-- 📰


port webnativeResponse : (Webnative.Response -> msg) -> Sub msg
