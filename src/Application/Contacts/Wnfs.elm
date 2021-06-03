module Contacts.Wnfs exposing (..)

import CAIP
import ChainID
import Contact exposing (Contact)
import Json.Encode as Encode
import Radix exposing (..)
import Tag
import Webnative
import Webnative.Path as Path
import Wnfs exposing (Base(..))



-- 🛠


init : Webnative.Request
init =
    Wnfs.writeUtf8
        Private
        { path = contactsPath
        , tag = Tag.toString Tag.SavedContacts
        }
        "[]"


initBlockchains : Webnative.Request
initBlockchains =
    Wnfs.writeUtf8
        Private
        { path = blockchainsPath
        , tag = Tag.toString Tag.SavedBlockchains
        }
        (CAIP.defaultChainIds
            |> Encode.list ChainID.encodeChainID
            |> Encode.encode 0
        )


load : Webnative.Request
load =
    Wnfs.readUtf8
        Private
        { path = contactsPath
        , tag = Tag.toString Tag.LoadedContacts
        }


loadBlockchains : Webnative.Request
loadBlockchains =
    Wnfs.readUtf8
        Private
        { path = blockchainsPath
        , tag = Tag.toString Tag.LoadedBlockchains
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
