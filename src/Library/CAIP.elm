module CAIP exposing (..)

import Dict exposing (Dict)



-- 🌳


type alias ChainId =
    { namespace : String
    , reference : String

    -- Extra
    , label : String
    }



-- 🛠


chainIdsList : List ChainId
chainIdsList =
    [ -----------------------------------------
      -- EVM
      -----------------------------------------
      { namespace = "eip155"
      , reference = "1"
      , label = "Ethereum Mainnet"
      }
    , { namespace = "eip155"
      , reference = "100"
      , label = "xDAI Chain"
      }
    , { namespace = "eip155"
      , reference = "137"
      , label = "Matic Mainnet"
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
