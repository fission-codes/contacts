module View exposing (view)

import CAIP
import Chunky exposing (..)
import Contact
import Dict
import Dict.Extra as Dict
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
        (case model.userData.contacts of
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

            Success contacts ->
                case model.page of
                    Index ->
                        index contacts model

                    New context ->
                        new model.userData context model

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
            , "text-[15px]"
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


index contacts model =
    mainLayout
        [ UI.Kit.h2
            []
            [ Html.text "Addresses" ]

        --
        , chunk
            Html.div
            [ "flex"
            , "items-center"
            ]
            []
            [ UI.Kit.h3
                []
                [ Html.text "Blockchains" ]

            --
            , chunk
                Html.a
                [ "inline-block"
                , "ml-3"
                , "text-neutral-3"
                ]
                [ A.href "new/"
                , A.title "Add blockchain address"
                ]
                [ Icons.plusCircle [ S.class "w-4" ]
                ]
            ]

        --
        , case contacts of
            [] ->
                [ chunk
                    Html.a
                    [ "italic"
                    , "text-neutral-4"

                    -- Dark mode
                    ------------
                    , "dark:text-neutral-2"
                    ]
                    [ A.href "new/" ]
                    [ Html.text "You don't have any contacts yet, want to add one?" ]
                ]
                    |> UI.Kit.paragraph
                        []
                    |> List.singleton
                    |> chunk
                        Html.div
                        [ "flex-1"
                        , "mt-8"
                        ]
                        []

            _ ->
                contacts
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
                                , "items-center"
                                , "py-3"

                                -- Dark mode
                                ------------
                                , "dark:border-darkness-above"
                                ]
                                []
                                [ chunk
                                    Html.div
                                    [ "w-5/12" ]
                                    []
                                    [ Html.text contact.label ]
                                , chunk
                                    Html.div
                                    [ "text-neutral-4"
                                    , "truncate"
                                    , "w-5/12"
                                    ]
                                    []
                                    [ Html.text contact.address.accountAddress
                                    ]
                                , chunk
                                    Html.div
                                    [ "flex"
                                    , "items-center"
                                    , "justify-end"
                                    , "text-neutral-4"
                                    , "w-2/12"
                                    ]
                                    []
                                    [ chunk
                                        Html.button
                                        [ "hidden"
                                        , "text-neutral-3"

                                        --
                                        , "group-hover:inline-block"

                                        -- Touch
                                        --------
                                        , "no-hover:inline-block"
                                        ]
                                        [ A.title "Copy address"
                                        , { text = contact.address.accountAddress
                                          , notification = Just "📋 Copied blockchain address to clipboard"
                                          }
                                            |> CopyToClipboard
                                            |> E.onClick
                                        ]
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
        , case model.userData.name of
            Just username ->
                UI.Kit.footnote
                    []
                    [ Html.text "Signed in as "
                    , chunk
                        Html.button
                        [ "underline" ]
                        []
                        [ Html.text username ]
                    , Html.text "."
                    ]

            Nothing ->
                Html.text ""
        ]



-- NEW


new userData context model =
    mainLayout
        [ UI.Kit.bgBackButton { href = "../" }
        , Html.div [] [ UI.Kit.backButton { href = "../" } ]

        --
        , UI.Kit.h2
            []
            [ Html.text "Add a new contact" ]

        --
        , UI.Kit.formField
            []
            [ chunk
                Html.div
                [ "mt-4" ]
                []
                [ UI.Kit.label
                    []
                    [ Html.text "Type" ]

                --
                , UI.Kit.dropdownContainer
                    [ A.class "text-marker-yellow-shade dark:text-marker-yellow" ]
                    [ UI.Kit.dropdownIcon
                    , chunk
                        Html.select
                        [ "bg-marker-yellow-tint"
                        , "bg-none"
                        , "border-2"
                        , "border-marker-yellow"
                        , "cursor-not-allowed"
                        , "rounded"
                        , "w-full"

                        --
                        , "focus:ring-transparent"
                        , "focus:border-marker-yellow"

                        -- Dark mode
                        ------------
                        , "dark:bg-marker-yellow-shade"
                        , "dark:border-opacity-20"
                        ]
                        [ A.disabled True ]
                        [ Html.option
                            []
                            [ Html.text "Blockchain address" ]
                        ]
                    ]
                ]
            ]

        --
        , chunk
            Html.form
            []
            [ E.onSubmit (AddNewContact context) ]
            [ UI.Kit.formField
                []
                [ UI.Kit.label
                    []
                    [ Html.text "Label" ]
                , UI.Kit.textField
                    [ A.type_ "text"
                    , A.placeholder "Main ETH account"
                    , A.required True
                    , E.onInput
                        (\a ->
                            GotUpdatedNewContext
                                { context | label = a }
                        )
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
                    [ E.onInput
                        (\a ->
                            GotUpdatedNewContext
                                { context | chainID = Just a }
                        )
                    ]
                    (userData.blockchainIds
                        |> RemoteData.withDefault CAIP.defaultChainIds
                        |> Dict.groupBy .group
                        |> Dict.toList
                        |> List.sortBy Tuple.first
                        |> List.map
                            (\( label, group ) ->
                                group
                                    |> List.map
                                        (\c ->
                                            Html.option
                                                [ A.value (CAIP.chainIdToString c)
                                                , A.selected False -- TODO
                                                ]
                                                [ Html.text c.label ]
                                        )
                                    |> Html.optgroup
                                        [ A.attribute "label" label ]
                            )
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
                    , A.required True
                    , E.onInput
                        (\a ->
                            GotUpdatedNewContext
                                { context | accountAddress = a }
                        )
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
                    , E.onInput
                        (\a ->
                            GotUpdatedNewContext
                                { context | notes = a }
                        )
                    ]
                    []
                ]

            --
            , UI.Kit.formField
                []
                [ chunk
                    Html.button
                    [ "bg-neutral-4"
                    , "border-0"
                    , "font-medium"
                    , "p-3"
                    , "rounded"
                    , "text-white"
                    , "w-full"

                    --
                    , "focus:bg-neutral-3"
                    , "focus:outline-none"
                    , "focus:ring-transparent"

                    -- Dark mode
                    ------------
                    , "dark:bg-neutral-2"
                    , "dark:text-neutral-5"

                    --
                    , "dark:focus:bg-neutral-3"
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
