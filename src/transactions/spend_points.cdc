// spend_points.cdc
import FungibleToken from 0x01
import NonFungibleToken from 0x02
import RewardsContract from 0x03

// This transaction allows the user to spend tokens on an item that is currently in the retailer's 
// rewards list. The amount of fungible tokens it costs is already given inside the retailer's 
// rewards resource so we know how much to deduct/if the customer has enough in the first place

// NOTE: Setup for Customer, Setup for Retailer, Earning Points and Create Reward must be run prior to this transaction.
// The User should also meet the required amount of tokens or this will not work, and it will be logged to the console.

// SIGNED BY: CUSTOMER
transaction {
    let CustomerCollection: &{NonFungibleToken.NFTReceiver}
    let CustomerVaultToWithdraw: &FungibleToken.Vault{FungibleToken.Balance, FungibleToken.Provider}
    let CostOfItem: UFix64
    
    prepare(acct: AuthAccount) {
        // Borrows a reference to the retailer's rewards so we can see if the item exists and
        // how much it costs
        let retailerAccount = getAccount(0x05)
        let RetailerRewards = retailerAccount.getCapability(/public/RewardsList)!
                                .borrow<&RewardsContract.Rewards>()
                                ?? panic("Could not borrow rewards resource")

        // If the item does not exist, panic
        if RetailerRewards.itemExists(name: "Water Bottle") == false {
            panic("Item does not exist!")
        }

        // Record the cost of the item (found in the retailer's list of rewards)
        let cost = RetailerRewards.costOfItem(name: "Water Bottle")
        self.CostOfItem = cost

        // Borrows a reference by using a capability to the customer's NFT collection
        // so we can deposit into this collection
        self.CustomerCollection = acct.getCapability(/public/NFTReceiver)!
                                    .borrow<&{NonFungibleToken.NFTReceiver}>()
                                    ?? panic("Could not borrow owner's NFTCollection reference") 

        // Borrows a reference by using a capability to the customer's fungible token vault
        // so that we can withdraw tokens and check the vault's balance
        let customerVaultToWithdrawTemp = acct.getCapability(/public/MainReceiver)!
                                        .borrow<&FungibleToken.Vault{FungibleToken.Balance, FungibleToken.Provider}>()
                                        ?? panic("Could not borrow owner's vault reference")                                

        if customerVaultToWithdrawTemp.mapTokensToRetailer["McDonalds"]! < cost {
            panic("Not enough tokens at this retailer!")
        }

        self.CustomerVaultToWithdraw = customerVaultToWithdrawTemp
    }

    execute {
        let NFTMinterAccount = getAccount(0x05)

        // Borrow a reference to the retailer's NFT Minter so they can mint tokens into the user's account
        let NFTMinterRef = NFTMinterAccount.getCapability(/public/PubNFTMinter)!
                            .borrow<&NonFungibleToken.NFTMinter>()
                            ?? panic("Could not borrow NFTMinter")

        // The retailer mints the new NFT and deposits it into the customer's collection
        NFTMinterRef.mintNFT(recipient: self.CustomerCollection, retailer: "McDonalds", item: "Water Bottle")

        log("Minted an NFT and put it in the customer's account")
        
        // The cost of the item in points is deducted from the user's account
        let removedTokensVault <- self.CustomerVaultToWithdraw.withdraw(amount: self.CostOfItem, retailer: "McDonalds")
        destroy removedTokensVault

        log("Took 30 points away")  
    }

}