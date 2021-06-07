module Page exposing (..)

import CAIP



-- 🌳


type Page
    = Edit EditContext String
    | Index IndexContext
    | New NewContext


type alias EditContext =
    { accountAddress : Maybe String
    , chainID : Maybe String
    , label : Maybe String
    , notes : Maybe String
    }


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


edit : EditContext
edit =
    { accountAddress = Nothing
    , chainID = Nothing
    , label = Nothing
    , notes = Nothing
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
