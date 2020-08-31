// readRewards.cdc

import FungibleToken from 0x01
import NonFungibleToken from 0x02
import RewardsContract from 0x03

// This script prints the NFTs that account 0x01 has for sale.
pub fun main(): {String: UFix64} {
    // 0x03 represents the retailer we would like to read the rewards from
    let retailer = getAccount(0x05)

    // Borrows a reference to the retailer's rewards list
    let retailerRewards = retailer.getCapability(/public/RewardsList)!
                                .borrow<&RewardsContract.Rewards>()
                                ?? panic("Could not borrow rewards resource")

    // Logs the rewards out, each one is the name of the reward (aka the item you receive) and the
    // cost of that reward in Fungible Tokens
    log(retailerRewards.getRewards())

    return retailerRewards.getRewards()
}
