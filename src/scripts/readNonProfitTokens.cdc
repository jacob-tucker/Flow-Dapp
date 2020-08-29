// readNonProfitTokens.cdc

import NonFungibleToken from 0x02

// This script reads all the NFTs a non-profit holds to see the tokens that customers have donated there for their cause

pub fun main() {
    let nonprofitAccount = getAccount(0x06)

    // Find the public Receiver capability for the user's collection
    let capability = nonprofitAccount.getCapability(/public/NFTReceiver)!
                        .borrow<&{NonFungibleToken.NFTReceiver}>()
                        ?? panic("Could not borrow nft collection reference from nonprofit")

     // Print both collections as arrays of IDs
    log("Nonprofit 1 NFTs")
    log(capability.getItems())
}

