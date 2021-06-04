module Page exposing (..)

import CAIP



-- 🌳


type Page
    = Index IndexContext
    | New NewContext


type alias IndexContext =
    { confirmRemove : Bool
    , selectedContact : Maybe Int
    }


type alias NewContext =
    { accountAddress : String
    , chainID : Maybe String
    , label : String
    , notes : String
    }


index : IndexContext
index =
    { confirmRemove = False
    , selectedContact = Nothing
    }


new : NewContext
new =
    { accountAddress = ""
    , chainID = Nothing
    , label = ""
    , notes = ""
    }
