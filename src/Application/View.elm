module View exposing (view)

import CAIP
import Chunky exposing (..)
import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Loaders
import Page exposing (Page(..))
import Radix exposing (Model, Msg(..))
import RemoteData exposing (RemoteData(..))
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
        (case model.userData of
            NotAsked ->
                [ notAuthorised ]

            Loading ->
                [ chunk
                    Html.div
                    [ "flex"
                    , "flex-col"
                    , "h-screen"
                    , "items-center"
                    , "justify-center"
                    ]
                    []
                    [ Loaders.tailSpin 30 "#fff"
                    , chunk
                        Html.div
                        [ "italic"
                        , "mt-4"
                        , "text-white"
                        ]
                        []
                        [ Html.text "Loading data" ]
                    ]
                ]

            Success userData ->
                case model.page of
                    Index ->
                        new model

            Failure error ->
                -- TODO
                [ Html.text error ]
        )



-- AUTH


notAuthorised =
    chunk
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
            [ Html.text "Contacts" ]

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
            [ E.onClick SignIn ]
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



-- INDEX


index userData model =
    mainLayout
        [ UI.Kit.h2
            []
            [ Html.text "Addresses" ]

        --
        , UI.Kit.paragraph
            []
            [ Html.em
                [ A.class "text-neutral-3" ]
                [ Html.text "You don't have any contacts yet, want to add one?" ]
            ]
        ]



-- NEW


new model =
    mainLayout
        [ UI.Kit.h2
            []
            [ Html.text "Add a new contact" ]

        --
        , [ chunk
                Html.span
                [ "leading-none"
                , "mt-px"
                ]
                []
                [ Html.text "⛓" ]
          , chunk
                Html.span
                [ "ml-1" ]
                []
                [ Html.text "Blockchain address" ]
          ]
            |> chunk
                Html.span
                [ "inline-flex"
                , "items-center"
                ]
                []
            |> List.singleton
            |> chunk
                Html.div
                [ "pt-px" ]
                []
            |> List.singleton
            |> chunk
                Html.div
                [ "bg-marker-yellow-tint"
                , "max-w-sm"
                , "mt-8"
                , "p-3"
                , "rounded"
                , "text-white"
                , "text-opacity-50"

                -- Dark mode
                ------------
                , "dark:bg-marker-yellow-shade"
                , "dark:text-opacity-50"
                ]
                []

        --
        , chunk
            Html.form
            [ "mt-16" ]
            []
            [ UI.Kit.formField
                []
                [ UI.Kit.label
                    []
                    [ Html.text "Label" ]
                , UI.Kit.textField
                    [ A.type_ "text"
                    , A.placeholder "Main ETH account"
                    ]
                    []
                ]

            --
            , UI.Kit.formField
                []
                [ UI.Kit.label
                    []
                    [ Html.text "Chain (& Network)" ]
                , UI.Kit.dropdown
                    []
                    (List.map
                        (\c ->
                            Html.option
                                [ A.value (CAIP.chainIdToString c) ]
                                [ Html.text c.label ]
                        )
                        CAIP.chainIds
                    )
                ]

            --
            , UI.Kit.formField
                []
                [ UI.Kit.label
                    []
                    [ Html.text "Address" ]
                , UI.Kit.textField
                    [ A.type_ "text"
                    , A.placeholder "0xab16a96d359ec26a11e2c2b3d8f8b8942d5bfcdb"
                    ]
                    []
                ]

            --
            , UI.Kit.formField
                []
                [ UI.Kit.label
                    []
                    [ Html.text "Notes" ]
                , UI.Kit.textArea
                    [ A.rows 3
                    ]
                    []
                ]

            --
            , UI.Kit.formField
                []
                [ chunk
                    Html.button
                    [ "bg-neutral-4"
                    , "font-medium"
                    , "mt-3"
                    , "p-3"
                    , "rounded"
                    , "text-white"
                    , "w-full"

                    -- Dark mode
                    ------------
                    , "dark:bg-neutral-2"
                    , "dark:text-neutral-5"
                    ]
                    []
                    [ Html.text "Add contact" ]
                ]
            ]
        ]



-- 🖼


mainLayout nodes =
    nodes
        |> chunk
            Html.div
            [ "bg-white"
            , "max-w-lg"
            , "min-h-screen"
            , "px-10"
            , "py-12"
            , "w-full"

            -- Dark mode
            ------------
            , "dark:bg-darkness"

            -- Responsive
            -------------
            , "md:max-w-screen-sm"
            , "lg:max-w-screen-md"
            ]
            []
        |> List.singleton
        |> chunk
            Html.div
            [ "flex"
            , "flex-col"
            , "items-end"
            ]
            []
        |> List.singleton
