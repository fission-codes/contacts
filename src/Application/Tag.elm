module Tag exposing (..)


type Tag
    = Untagged


toString : Tag -> String
toString tag =
    case tag of
        Untagged ->
            "Untagged"


fromString : String -> Result String Tag
fromString string =
    case string of
        "Untagged" ->
            Ok Untagged

        _ ->
            Err "Invalid tag"
