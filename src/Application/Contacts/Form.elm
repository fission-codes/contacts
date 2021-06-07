module Contacts.Form exposing (..)

import CAIP
import Chunky exposing (..)
import Dict
import Dict.Extra as Dict
import Html
import Html.Attributes as A
import Html.Events as E
import Page
import RemoteData
import UI.Kit



-- SPECIAL FIELDS


typeSelector =
    UI.Kit.formField
        [ A.class "mt-4" ]
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



-- REGULAR FIELDS


address onInput value =
    UI.Kit.formField
        []
        [ UI.Kit.label
            []
            [ Html.text "Address" ]
        , UI.Kit.textField
            [ A.type_ "text"
            , A.placeholder "0xab16a96d359ec26a11e2c2b3d8f8b8942d5bfcdb"
            , A.required True
            , A.value value
            , E.onInput onInput
            ]
            []
        ]


chainID onInput value userData =
    UI.Kit.formField
        []
        [ UI.Kit.label
            []
            [ Html.text "Chain (& Network)" ]
        , UI.Kit.dropdown
            [ E.onInput onInput ]
            (userData.blockchainIds
                |> RemoteData.map .groups
                |> RemoteData.withDefault CAIP.defaultChainIdGroups
                |> List.map
                    (\( groupLabel, group ) ->
                        group
                            |> List.map
                                (\( chainIdString, chainId ) ->
                                    Html.option
                                        [ A.value chainIdString
                                        , A.selected (value == Just chainIdString)
                                        ]
                                        [ Html.text chainId.label ]
                                )
                            |> Html.optgroup
                                [ A.attribute "label" groupLabel ]
                    )
            )
        ]


label onInput value =
    UI.Kit.formField
        []
        [ UI.Kit.label
            []
            [ Html.text "Label" ]
        , UI.Kit.textField
            [ A.type_ "text"
            , A.placeholder "Main ETH account"
            , A.required True
            , A.value value
            , E.onInput onInput
            ]
            []
        ]


notes onInput value =
    UI.Kit.formField
        []
        [ UI.Kit.label
            []
            [ Html.text "Notes" ]
        , UI.Kit.textArea
            [ A.rows 3
            , A.value value
            , E.onInput onInput
            ]
            []
        ]
