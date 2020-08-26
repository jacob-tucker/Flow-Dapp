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
        if RetailerRewards.itemExists(name: "Water Bottle") == true {
            panic("Item already exists!")
        }

        // Creates the new reward
        RetailerRewards.createReward(name: "Water Bottle", points: UFix64(30), ucvNumber: UFix64(5), otherRetailers: ["Burger King"])

        log("Created reward")
    } 

    execute {

    }
}