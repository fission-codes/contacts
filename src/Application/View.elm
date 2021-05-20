module View exposing (view)

import Chunky exposing (..)
import Html exposing (Html)
import Html.Attributes as A
import Page exposing (Page(..))
import Radix exposing (Model, Msg(..))


view : Model -> Html Msg
view model =
    chunk
        Html.main_
        [ "bg-neutral-6"
        , "font-body"
        , "min-h-screen"
        , "text-neutral-1"

        -- Dark mode
        ------------
        , "dark:bg-neutral-1"
        , "dark:text-neutral-6"
        ]
        [ A.style "text-rendering" "geometricPrecision" ]
        []
