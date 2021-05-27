module View exposing (view)

import CAIP
import Chunky exposing (..)
import Contact
import Dict
import Heroicons.Solid as Icons
import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Loaders
import Page exposing (Page(..))
import Radix exposing (Model, Msg(..))
import RemoteData exposing (RemoteData(..))
import Svg.Attributes as S
import UI.Kit


view : Model -> Html Msg
view model =
    chunk
        Html.main_
        [ "font-body"
        , "min-h-screen"
        , "text-neutral-2"

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
                        index userData model

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
        , chunk
            Html.div
            [ "flex" ]
            []
            [ UI.Kit.h3
                []
                [ Html.text "Blockchains" ]

            --
            , chunk
                Html.button
                [ "ml-3"
                , "text-neutral-3"
                ]
                [ A.title "Add blockchain address" ]
                [ Icons.plusCircle [ S.class "w-4" ]
                ]
            ]

        --
        -- , UI.Kit.paragraph
        --     []
        --     [ Html.em
        --         [ A.class "text-neutral-3" ]
        --         [ Html.text "You don't have any contacts yet, want to add one?" ]
        --     ]
        , [ { address =
                { accountAddress = "0xab16a96d359ec26a11e2c2b3d8f8b8942d5bfcdb"
                , chainID = "eip155:1"
                , addressType = "BLOCKCHAIN_ADDRESS"
                }
            , createdAt = "2021-05-26T16:03:03Z"
            , label = "Main ETH account"
            , modifiedAt = "2021-05-26T16:03:03Z"
            , notes = Nothing
            }
          , { address =
                { accountAddress = "0xab16a96d359ec26a11e2c2b3d8f8b8942d5bfcdb"
                , chainID = "eip155:137"
                , addressType = "BLOCKCHAIN_ADDRESS"
                }
            , createdAt = "2021-05-26T16:03:03Z"
            , label = "Treasure"
            , modifiedAt = "2021-05-26T16:03:03Z"
            , notes = Nothing
            }
          , { address =
                { accountAddress = "0xab16a96d359ec26a11e2c2b3d8f8b8942d5bfcdb"
                , chainID = "eip155:100"
                , addressType = "BLOCKCHAIN_ADDRESS"
                }
            , createdAt = "2021-05-26T16:03:03Z"
            , label = "xDAI test account"
            , modifiedAt = "2021-05-26T16:03:03Z"
            , notes = Nothing
            }
          ]
            |> List.sortBy
                .label
            |> List.map
                (\contact ->
                    chunk
                        Html.div
                        [ "border-b"
                        , "border-neutral-6"
                        , "flex"
                        , "group"
                        , "py-3"
                        ]
                        []
                        [ chunk
                            Html.div
                            [ "w-7/12" ]
                            []
                            [ Html.text contact.label ]
                        , chunk
                            Html.div
                            [ "text-neutral-4"
                            , "w-4/12"
                            ]
                            []
                            [ CAIP.chainIds
                                |> Dict.get contact.address.chainID
                                |> Maybe.map .label
                                |> Maybe.withDefault ""
                                |> Html.text
                            ]
                        , chunk
                            Html.div
                            [ "text-neutral-4"
                            , "text-right"
                            , "w-1/12"
                            ]
                            []
                            [ chunk
                                Html.button
                                [ "hidden"
                                , "text-neutral-3"

                                --
                                , "group-hover:inline-block"
                                ]
                                []
                                [ Icons.clipboardCopy [ S.class "w-4" ]
                                ]
                            ]
                        ]
                )
            |> chunk
                Html.div
                [ "flex-1"
                , "mt-8"
                ]
                []

        --
        , UI.Kit.footnote
            []
            [ Html.text "Signed in as "
            , chunk
                Html.button
                [ "underline" ]
                []
                [ Html.text "username" ]
            , Html.text "."
            ]
        ]



-- NEW


new model =
    mainLayout
        [ UI.Kit.bgBackButton
        , UI.Kit.backButton

        --
        , UI.Kit.h2
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
                , "text-black"
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
                        CAIP.chainIdsList
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
            , "flex"
            , "flex-col"
            , "max-w-lg"
            , "min-h-screen"
            , "px-6"
            , "py-10"
            , "relative"
            , "w-full"

            -- Dark mode
            ------------
            , "dark:bg-darkness"

            -- Responsive
            -------------
            , "md:max-w-screen-sm"
            , "lg:max-w-screen-md"

            --
            , "md:px-10"
            , "md:py-12"
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
