module Tag exposing (..)


type Tag
    = Untagged
      --
    | LoadedBlockchains
    | LoadedContacts
    | SavedBlockchains
    | SavedContacts


toString : Tag -> String
toString tag =
    case tag of
        Untagged ->
            "Untagged"

        --
        LoadedBlockchains ->
            "LoadedBlockchains"

        LoadedContacts ->
            "LoadedContacts"

        SavedBlockchains ->
            "SavedBlockchains"

        SavedContacts ->
            "SavedContacts"


fromString : String -> Result String Tag
fromString string =
    case string of
        "Untagged" ->
            Ok Untagged

        --
        "LoadedBlockchains" ->
            Ok LoadedBlockchains

        "LoadedContacts" ->
            Ok LoadedContacts

        "SavedBlockchains" ->
            Ok SavedBlockchains

        "SavedContacts" ->
            Ok SavedContacts

        --
        _ ->
            Err "Invalid tag"
