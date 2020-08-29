// instagram_ad.cdc
import FungibleToken from 0x01
import NonFungibleToken from 0x02

// SIGNED BY: RETAILER

// This transaction occurs when a user posts on instagram promoting the retailer. They will
// earn points and receive an updated UCV value for their good deeds (less than what they would
// get for purchasing at the retailer, though).

transaction {

    let FTMinterRef: &FungibleToken.VaultMinter
    let NFTMinterRef: &NonFungibleToken.NFTMinter

    prepare(acct: AuthAccount) {
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
                                    .borrow<&{NonFungibleToken.NFTReceiver, NonFungibleToken.ReferenceUser}>()
                                    ?? panic("Could not borrow owner's NFT collection")
        // The retailer mints the new tokens and deposits them into the customer's vault, taking into
        // account 5% of the UCV value.
        self.FTMinterRef.mintTokens(amount: UFix64(10) + customerCollection.myReferenceNFT.UCV * UFix64(0.05), recipient: customerVault, retailerName: "McDonalds")

        log("Retailer minted >= 10 points and gave them to the customer")

        customerCollection.myReferenceNFT.ad(retailer: "McDonalds")

        log("Updated customer's UCV and CV value")
    }

}