// create_reward.cdc

import RewardsContract from 0x03

// This transaction is meant for retailer's to create a new reward for customers

// NOTE: Setup for Retailer must be signed before this tra

// SIGNED BY: RETAILER


transaction {


    prepare(acct: AuthAccount) {
        // Borrows a reference to the retailer's rewards resource so they can create a new reward
        // with a name and number of points
        let RetailerRewards = acct.borrow<&RewardsContract.Rewards>(from: /storage/Rewards)
                                ?? panic("Could not borrow rewards resource")

        // If the item does not exist, panic
        if RetailerRewards.itemExists(name: "Coffee") == true {
            panic("Item already exists!")
        }

        // Creates the new reward
        // Specifies the NFT they will receive (a water bottle)
        // The amount of points (from this retailer) the NFT will cost 
        // THE NEXT FIELDS ONLY APPLY IF THE USER USES ANOTHER RETAILER'S TOKENS TO PURCHASE THE REWARD
        // ucvNumber, which is the minimum UCV the customer must have to use tokens from another retailer
        // otherRetailers, which is a list of retailers the user is allowed to spend their tokens from to help out with thr purchase
        // minTokensPercent, which is a percent of the amount of tokens the user must spend from THIS retailer in the transaction
        // multiplier, which multiplies the base cost of the NFT by a number to get a new cost if incorporating another r
        RetailerRewards.createReward(name: "Coffee", points: UFix64(30), ucvNumber: UFix64(5), cvNumber: UFix64(0), otherRetailers: ["Jerrys Deli"], minTokensPercent: UFix64(0.5), multiplier: UFix64(1.25))

        log("Created reward")
    }

    execute {

    }
}