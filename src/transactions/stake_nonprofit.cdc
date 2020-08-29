// stake_nonprofit.cdc
import NonFungibleToken from 0x02

// SIGNED BY: CUSTOMER

// This transaction occurs when a user is giving one of their NFTs to a non-profit to stake their campaign

transaction {

    let CustomerCollection: &NonFungibleToken.Collection
    let NFTName: String

    prepare(acct: AuthAccount) {
        // Gets a reference to the customer's NFTCollection
        self.CustomerCollection = acct.borrow<&NonFungibleToken.Collection>(from: /storage/NFTCollection)
                                    ?? panic("Could not borrow the nonfungible token minter from the retailer")
        self.NFTName = "McDonalds:Water Bottle"
    }

    execute {
        // Gets the NonProfit account
        let nonprofitAccount = getAccount(0x06)

        // Gets a reference to the Non-profit's NFTCollection so we can deposit into it
        let NonProfitCollection = nonprofitAccount.getCapability(/public/NFTReceiver)!
                                    .borrow<&{NonFungibleToken.NFTReceiver}>()
                                    ?? panic("Could not borrow the nonfungible token minter from the retailer")

        // Withdraws the NFT from the customer's NFTCollection
        let nft <- self.CustomerCollection.withdraw(withdrawItem: self.NFTName)

        // Donates it to the non-profit's NFTCollection
        NonProfitCollection.deposit(token: <-nft)

        log("Donated an NFT to the Non-Profit!")

    }

}