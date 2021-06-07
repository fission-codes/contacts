module View exposing (view)

import CAIP
import Chunky exposing (..)
import Contact
import Contacts.Form as Form
import Dict
import Dict.Extra as Dict
import Heroicons.Solid as Icons
import Html exposing (Html)
import Html.Attributes as A
import Html.Events as E
import Html.Events.Extra as E
import Html.Extra as Html
import List.Extra as List
import Loaders
import Maybe.Extra as Maybe
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
        (case model.page of
            Index context ->
                if context.confirmRemove then
                    { context | confirmRemove = False }
                        |> GotUpdatedIndexContext
                        |> E.onClick
                        |> List.singleton

                else
                    []

            _ ->
                []
        )
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
                    Edit context uuid ->
                        model.userData.contacts
                            |> RemoteData.withDefault []
                            |> List.find (.uuid >> (==) uuid)
                            |> Maybe.map (edit model context)
                            |> Maybe.withDefault (notFound model)

                    Index context ->
                        index contacts context model

                    New context ->
                        new context model

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
        , "px-4"
        , "text-center"
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



-- EDIT


edit model context contact =
    mainLayout
        [ UI.Kit.backButtons { href = "../../" }

        --
        , UI.Kit.h2
            []
            [ Html.text "Edit contact" ]

        --
        , Form.typeSelector

        --
        , chunk
            Html.form
            []
            [ E.onSubmit (UpdateContact contact context) ]
            [ Form.label
                (\a ->
                    GotUpdatedEditContext
                        { context | label = Just a }
                )
                (Maybe.withDefault
                    contact.label
                    context.label
                )

            --
            , Form.chainID
                (\a ->
                    GotUpdatedEditContext
                        { context | chainID = Just a }
                )
                (Maybe.or
                    context.chainID
                    (Just contact.address.chainID)
                )
                model.userData

            --
            , Form.address
                (\a ->
                    GotUpdatedEditContext
                        { context | accountAddress = Just a }
                )
                (Maybe.withDefault
                    contact.address.accountAddress
                    context.accountAddress
                )

            --
            , Form.notes
                (\a ->
                    GotUpdatedEditContext
                        { context | notes = Just a }
                )
                (context.notes
                    |> Maybe.orElse contact.notes
                    |> Maybe.withDefault ""
                )

            --
            , UI.Kit.formField
                []
                [ UI.Kit.button
                    Html.button
                    [ A.class "p-3 w-full" ]
                    [ Html.text "Save contact" ]
                ]
            ]
        ]


notFound model =
    -- TODO
    [ Html.text "Can't find this contact" ]



-- INDEX


index contacts context model =
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
                    |> List.indexedMap
                        (indexContact context model)
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
                        [ A.title "Sign out"
                        , E.onClick SignOut
                        ]
                        [ Html.text username ]
                    , Html.text "."
                    ]

            Nothing ->
                Html.text ""
        ]


indexContact context model idx contact =
    let
        isSelected =
            context.selectedContact == Just idx

        removeEvent =
            if context.confirmRemove then
                RemoveContact { index = idx }

            else
                GotUpdatedIndexContext { context | confirmRemove = True }

        selectEvent =
            if isSelected then
                GotUpdatedIndexContext { context | confirmRemove = False, selectedContact = Nothing }

            else
                GotUpdatedIndexContext { context | confirmRemove = False, selectedContact = Just idx }
    in
    Html.div
        []
        [ -----------------------------------------
          -- ROW
          -----------------------------------------
          chunk
            Html.div
            [ "border-b"
            , "border-neutral-6"
            , "cursor-pointer"
            , "flex"
            , "group"
            , "items-center"
            , "py-3"

            -- Dark mode
            ------------
            , "dark:border-darkness-above"
            ]
            [ E.onClick selectEvent
            ]
            [ chunk
                Html.div
                [ "pr-3"
                , "w-5/12"
                ]
                []
                [ Html.text contact.label ]
            , chunk
                Html.div
                [ "duration-300"
                , "text-neutral-4"
                , "transition-opacity"
                , "truncate"
                , "w-5/12"

                --
                , if isSelected then
                    "opacity-0"

                  else
                    "opacity-100"
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
                        |> E.onClickStopPropagation
                    ]
                    [ Icons.clipboardCopy [ S.class "w-4" ]
                    ]
                ]
            ]

        -----------------------------------------
        -- DETAILS
        -----------------------------------------
        , if isSelected then
            chunk
                Html.div
                [ "bg-neutral-6"
                , "-mt-px"
                , "-mx-6"
                , "pb-8"
                , "pt-6"
                , "px-5"

                -- Responsive
                -------------
                , "md:-mx-10"
                , "md:px-8"

                -- Dark mode
                ------------
                , "dark:bg-darkness-above"
                ]
                []
                [ -- Address
                  ----------
                  UI.Kit.label
                    []
                    [ Html.text "Address" ]
                , chunk
                    Html.div
                    [ "break-all" ]
                    []
                    [ Html.text contact.address.accountAddress ]

                -- Notes
                --------
                , Html.div
                    []
                    (case contact.notes of
                        Just notes ->
                            [ UI.Kit.label
                                [ A.class "mt-6" ]
                                [ Html.text "Notes" ]
                            , chunk
                                Html.div
                                []
                                []
                                [ Html.text notes ]
                            ]

                        Nothing ->
                            []
                    )

                -- Manage
                ---------
                , UI.Kit.label
                    [ A.class "mt-6" ]
                    [ Html.text "Manage" ]
                , chunk
                    Html.div
                    [ "flex"
                    , "pt-1"
                    , "text-sm"
                    ]
                    []
                    [ UI.Kit.button
                        Html.button
                        [ E.onClick removeEvent

                        --
                        , A.class "px-2 py-1"

                        --
                        , if context.confirmRemove then
                            A.class "!bg-red"

                          else
                            A.class ""
                        ]
                        [ UI.Kit.buttonIcon Icons.minusCircle
                        , if context.confirmRemove then
                            Html.text "Confirm"

                          else
                            Html.text "Remove"
                        ]

                    -- , UI.Kit.button
                    --     Html.a
                    --     [ A.class "ml-2 px-2 py-1"
                    --     ]
                    --     [ UI.Kit.buttonIcon Icons.pencil
                    --     , Html.text "Edit"
                    --     ]
                    ]
                ]

          else
            Html.nothing
        ]



-- NEW


new context model =
    mainLayout
        [ UI.Kit.backButtons { href = "../" }

        --
        , UI.Kit.h2
            []
            [ Html.text "Add a new contact" ]

        --
        , Form.typeSelector

        --
        , chunk
            Html.form
            []
            [ E.onSubmit (AddNewContact context) ]
            [ Form.label
                (\a ->
                    GotUpdatedNewContext
                        { context | label = a }
                )
                context.label

            --
            , Form.chainID
                (\a ->
                    GotUpdatedNewContext
                        { context | chainID = Just a }
                )
                context.chainID
                model.userData

            --
            , Form.address
                (\a ->
                    GotUpdatedNewContext
                        { context | accountAddress = a }
                )
                context.accountAddress

            --
            , Form.notes
                (\a ->
                    GotUpdatedNewContext
                        { context | notes = a }
                )
                context.notes

            --
            , UI.Kit.formField
                []
                [ UI.Kit.button
                    Html.button
                    [ A.class "p-3 w-full" ]
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
