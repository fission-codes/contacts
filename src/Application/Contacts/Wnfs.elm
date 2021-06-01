module Contacts.Wnfs exposing (..)

import Contact exposing (Contact)
import Json.Encode as Encode
import Radix exposing (appPermissions, contactsPath)
import Tag
import Webnative
import Webnative.Path as Path
import Wnfs exposing (Base(..))



-- 🛠


load : Webnative.Request
load =
    Wnfs.readUtf8
        Private
        { path = contactsPath
        , tag = Tag.toString Tag.LoadedContacts
        }


save : List Contact -> Webnative.Request
save contacts =
    contacts
        |> Encode.list Contact.encodeContact
        |> Encode.encode 0
        |> Wnfs.writeUtf8
            Private
            { path = contactsPath
            , tag = Tag.toString Tag.SavedContacts
            }
