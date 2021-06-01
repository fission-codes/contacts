module Tag exposing (..)


type Tag
    = Untagged
      --
    | LoadedContacts
    | SavedContacts


toString : Tag -> String
toString tag =
    case tag of
        Untagged ->
            "Untagged"

        --
        LoadedContacts ->
            "LoadedContacts"

        SavedContacts ->
            "SavedContacts"


fromString : String -> Result String Tag
fromString string =
    case string of
        "Untagged" ->
            Ok Untagged

        --
        "LoadedContacts" ->
            Ok LoadedContacts

        "SavedContacts" ->
            Ok SavedContacts

        --
        _ ->
            Err "Invalid tag"
