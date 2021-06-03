module CAIP exposing (..)

import ChainID exposing (ChainID)
import Dict exposing (Dict)



-- 🌳


mainNet =
    "Main networks"


testNet =
    "Test networks"



-- 🛠


defaultChainIds : List ChainID
defaultChainIds =
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


chainIdToString : ChainID -> String
chainIdToString { namespace, reference } =
    namespace ++ ":" ++ reference
