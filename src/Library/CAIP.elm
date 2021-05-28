module CAIP exposing (..)

import Dict exposing (Dict)



-- 🌳


type alias ChainId =
    { namespace : String
    , reference : String

    -- Extra
    , label : String
    , group : String
    }


mainNet =
    "Main networks"


testNet =
    "Test networks"



-- 🛠


chainIdsList : List ChainId
chainIdsList =
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


chainIds : Dict String ChainId
chainIds =
    chainIdsList
        |> List.map (\a -> Tuple.pair (chainIdToString a) a)
        |> Dict.fromList


chainIdToString : ChainId -> String
chainIdToString { namespace, reference } =
    namespace ++ ":" ++ reference
