module View exposing (view)

import Chunky exposing (..)
import Html exposing (Html)
import Html.Attributes as A
import Page exposing (Page(..))
import Radix exposing (Model, Msg(..))
import UI.Kit


view : Model -> Html Msg
view model =
    chunk
        Html.main_
        [ "font-body"
        , "min-h-screen"
        , "text-neutral-1"

        -- Dark mode
        ------------
        , "dark:text-neutral-6"
        ]
        []
        (case model.page of
            Index ->
                [ chunk
                    Html.div
                    [ "flex"
                    , "flex-col"
                    , "h-screen"
                    , "items-center"
                    , "justify-center"
                    , "pb-8"
                    , "pt-5"
                    ]
                    []
                    [ UI.Kit.h1
                        []
                        [ Html.text "Address#Book" ]

                    --
                    , UI.Kit.intro
                        []
                        [ Html.text "Keep track of all your different wallet addresses."
                        ]

                    --
                    , chunk
                        Html.button
                        [ "bg-white"
                        , "font-medium"
                        , "inline-flex"
                        , "items-center"
                        , "leading-relaxed"
                        , "mt-10"
                        , "px-5"
                        , "py-2"
                        , "rounded-full"
                        , "text-[#BEBEC1]"
                        , "tracking-tight"
                        ]
                        []
                        [ chunk
                            Html.span
                            [ "mr-2" ]
                            []
                            [ UI.Kit.fissionIcon
                                { size = 12 }
                            ]
                        , Html.text "Sign in with Fission"
                        ]
                    ]
                ]
        )
