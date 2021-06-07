module CAIP exposing (..)

import ChainID exposing (ChainID)
import Dict exposing (Dict)
import Dict.Extra as Dict



-- 🌳


type alias ChainIdCollection =
    { list : List ChainID
    , groups : ChainIdGroups
    }


type alias ChainIdGroups =
    List ( String, List ( String, ChainID ) )


mainNet =
    "Main networks"


testNet =
    "Test networks"


defaultChainIds : ChainIdCollection
defaultChainIds =
    { list = defaultChainIdsList
    , groups = defaultChainIdGroups
    }


defaultChainIdsList : List ChainID
defaultChainIdsList =
    List.sortBy
        .label
        [ -----------------------------------------
          -- EVM
          -----------------------------------------
          { namespace = "eip155"
          , reference = "1"
          , label = "Ethereum Mainnet"
          , group = mainNet
          }
        , { namespace = "eip155"
          , reference = "100"
          , label = "xDAI Chain"
          , group = mainNet
          }
        , { namespace = "eip155"
          , reference = "137"
          , label = "Matic Mainnet"
          , group = mainNet
          }
        ]


defaultChainIdGroups : ChainIdGroups
defaultChainIdGroups =
    chainIdsListToGroups defaultChainIdsList



-- 🛠


chainIdsListToDict : List ChainID -> Dict String ChainID
chainIdsListToDict list =
    list
        |> List.map
            (\c ->
                Tuple.pair (chainIdToString c) c
            )
        |> Dict.fromList


chainIdsListToGroups : List ChainID -> ChainIdGroups
chainIdsListToGroups list =
    list
        |> Dict.groupBy .group
        |> Dict.toList
        |> List.sortBy Tuple.first
        |> List.map
            (Tuple.mapSecond
                (List.map
                    (\c -> Tuple.pair (chainIdToString c) c)
                )
            )


chainIdToString : ChainID -> String
chainIdToString { namespace, reference } =
    namespace ++ ":" ++ reference
