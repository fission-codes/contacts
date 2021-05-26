module CAIP exposing (..)

-- 🌱


type alias ChainId =
    { namespace : String
    , reference : String

    -- Extra
    , label : String
    }



-- 🛠


chainIds : List ChainId
chainIds =
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


chainIdToString : ChainId -> String
chainIdToString { namespace, reference } =
    namespace ++ ":" ++ reference
