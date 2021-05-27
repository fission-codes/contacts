module Page exposing (..)

-- 🌳


type Page
    = Index
    | New NewContext


type alias NewContext =
    { accountAddress : String
    , chainId : String
    , label : String
    , notes : String
    }


new : NewContext
new =
    { accountAddress = ""
    , chainId = ""
    , label = ""
    , notes = ""
    }
