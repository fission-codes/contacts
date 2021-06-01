module Contacts.AddressType exposing (..)


type AddressType
    = BlockchainAddress


toString : AddressType -> String
toString addressType =
    case addressType of
        BlockchainAddress ->
            "BLOCKCHAIN_ADDRESS"
