// earning_points.cdc

import FungibleToken from 0x01
import NonFungibleToken from 0x02

// This transaction is signed by the retailer and then deposits fungible tokens (points) into
// the customer's account. 

// NOTE: Setup for Customer and Setup for Retailer must be run prior to this transact

// SIGNED BY: RETAILER
transaction {

    let FTMinterRef: &FungibleToken.VaultMinter
    let NFTMinterRef: &NonFungibleToken.NFTMinter

    prepare(acct: AuthAccount) {
    /*  You can do this without capabilities too, but it's more secure the second way.
        self.FTMinterRef = acct.borrow<&FungibleToken.VaultMinter>(from: /storage/MainMinter)
                                ?? panic("Could not borrow the retailer's FT minting reference")
    */
        // Gets a reference to the fungible token minter of the retailer
        self.FTMinterRef = acct.getCapability(/private/PrivFTMinter)!
                                .borrow<&FungibleToken.VaultMinter>()
                                ?? panic("Could not borrow the fungible token minter from the retailer")
        // Gets a reference to the nonfungible token minter of the retailer
        self.NFTMinterRef = acct.getCapability(/public/PubNFTMinter)!
                                .borrow<&NonFungibleToken.NFTMinter>()
                                ?? panic("Could not borrow the nonfungible token minter from the retailer")
    }

    execute {
        // Gets the PublicAccount for the customer
        let customerAccount = getAccount(0x04)

        // Borrows a reference by using a capability to the customer's fungible token vault
        let customerVault = customerAccount.getCapability(/public/MainReceiver)!
                                .borrow<&FungibleToken.Vault{FungibleToken.Receiver, FungibleToken.Balance}>()
                                ?? panic("Could not borrow owner's vault reference")

        let customerCollection = customerAccount.getCapability(/public/NFTReceiver)!
                                    .borrow<&{NonFungibleToken.NFTReceiver}>()
                                    ?? panic("Could not borrow owner's NFT collection")
        // The retailer mints the new tokens and deposits them into the customer's vau
        self.FTMinterRef.mintTokens(amount: UFix64(10) + customerCollection.myReferenceNFT.UCV * UFix64(0.1), recipient: customerVault, retailerName: "McDonalds")

        log("Retailer minted 10 points and gave them to the customer")

        customerCollection.myReferenceNFT.purchase()

        log("Updated customer's UCV value")

    }
}