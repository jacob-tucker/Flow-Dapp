// remove_reward.cdc

import RewardsContract from 0x03

// This transaction is meant for retailer's to remove an existing reward for customers

// SIGNED BY: RETAILER

transaction {

    prepare(acct: AuthAccount) {
        // Borrows a reference to the retailer's rewards resource so they can remove a reward
        let RetailerRewards = acct.borrow<&RewardsContract.Rewards>(from: /storage/Rewards)
                                ?? panic("Could not borrow rewards resource")
        
        // If the item does not exist, panic
        if RetailerRewards.itemExists(name: "Water Bottle") == false {
            panic("Item does not exist!")
        }

        // Removes the new reward
        RetailerRewards.removeReward(name: "Water Bottle")

        log("Removed reward")
    }

    execute {

    }
}