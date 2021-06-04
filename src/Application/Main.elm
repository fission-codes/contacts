module Main exposing (main)

import Browser
import Radix exposing (Flags, Model, Msg(..))
import State
import View



-- ⛩


main : Program Flags Model Msg
main =
    Browser.application
        { init = State.init
        , subscriptions = State.subscriptions
        , update = State.update
        , onUrlChange = UrlChanged
        , onUrlRequest = UrlRequested
        , view = view
        }



-- 🖼


view : Model -> Browser.Document Msg
view model =
    { title = "Contacts"
    , body = [ View.view model ]
    }
