module Page exposing (..)

import CAIP



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
    , chainId =
        CAIP.chainIdsList
            |> List.head
            |> Maybe.map CAIP.chainIdToString
            |> Maybe.withDefault ""
    , label = ""
    , notes = ""
    }
