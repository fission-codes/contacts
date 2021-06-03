module Page exposing (..)

import CAIP



-- 🌳


type Page
    = Index
    | New NewContext


type alias NewContext =
    { accountAddress : String
    , chainID : Maybe String
    , label : String
    , notes : String
    }


new : NewContext
new =
    { accountAddress = ""
    , chainID = Nothing
    , label = ""
    , notes = ""
    }
