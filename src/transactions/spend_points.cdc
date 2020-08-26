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

    // Whether or not the customer would like to use the other retailer
    let OtherRetailerBool: Bool
    // The other retailer they would like to incorporate
    let OtherRetailer: String
    // The allowed retailers
    let AllowedRetailers: [String]
    // The minimum UCV value that the customer must have to be able to use 
    // the other tokens for this reatiler's NFT
    let MinUCV: UFix64
    
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

        // Record the cost of the item (found in the retailer's list of rewards) by getting the reward resource first
        let reward <- RetailerRewards.getReward(name: "Water Bottle")
        // Record the cost of the reward
        let cost = reward.points
        let allowedRetailers = reward.allowedRetailers
        let minUCV = reward.minimumUCVForOthers
        // Put the reward back in the dictionary by using the double <- move operator
        let oldReward <- RetailerRewards.rewards["Water Bottle"] <- reward
        // Destroy the temp reward 
        destroy oldReward

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

        self.CustomerVaultToWithdraw = customerVaultToWithdrawTemp

        // This is saying the user would like to use burger king in their transaction
        self.OtherRetailerBool = true
        self.OtherRetailer = "Burger King"
        self.CostOfItem = cost
        self.AllowedRetailers = allowedRetailers
        self.MinUCV = minUCV

    }

    execute {
        let NFTMinterAccount = getAccount(0x05)

        // Borrow a reference to the retailer's NFT Minter so they can mint tokens into the user's account
        let NFTMinterRef = NFTMinterAccount.getCapability(/public/PubNFTMinter)!
                            .borrow<&NonFungibleToken.NFTMinter>()
                            ?? panic("Could not borrow NFTMinter")

        // Checks to see if another retailer's tokens will be withdrawn
        if (self.OtherRetailerBool) {
            // Makes sure that the retailer the customer wants to use to help pay for the NFT is in the allowed
            // category of the reward, and also makes sure the customer meets the UCV requirements
            if (self.AllowedRetailers.contains(self.OtherRetailer) && self.CustomerCollection.myReferenceNFT.UCV > self.MinUCV) {
                // The cost of the item in points is deducted from the user's account
                let removedTokensVault <- self.CustomerVaultToWithdraw.withdraw(amount: self.CostOfItem - UFix64(10), retailer: "McDonalds")
                destroy removedTokensVault

                // Removes tokens from the other retailer as well
                let removedTokensOtherVault <- self.CustomerVaultToWithdraw.withdraw(amount: UFix64(10), retailer: self.OtherRetailer)
                destroy removedTokensOtherVault
                
                log("Took 30 points away")  

                // The retailer mints the new NFT and deposits it into the customer's collection
                NFTMinterRef.mintNFT(recipient: self.CustomerCollection, retailer: "McDonalds", item: "Water Bottle")

                log("Minted an NFT and put it in the customer's account")
            } else {
                panic("This retailer is not allowed or you do not meet the UCV requirements")
            }
        } else {
            // This is if they are just using tokens from the retailer they are getting the NFT from
            // The cost of the item in points is deducted from the user's account
            let removedTokensVault <- self.CustomerVaultToWithdraw.withdraw(amount: self.CostOfItem, retailer: "McDonalds")
            destroy removedTokensVault

            log("Took 30 points away")  

            // The retailer mints the new NFT and deposits it into the customer's collection
            NFTMinterRef.mintNFT(recipient: self.CustomerCollection, retailer: "McDonalds", item: "Water Bottle")

            log("Minted an NFT and put it in the customer's account")
        }
        
    }

}