// readTokens.cdc

import FungibleToken from 0x01
import NonFungibleToken from 0x02

// This script checks that the customer has points after 
// the retailer gives it to them after a purchase ("Earning Points" transaction)
// Also checks to see if the user has an NFT in their collection if they've reached a certain
// thresh-hold

// STEPS TO GET THIS TO WORK:
// "Setup for Customer"
// "Setup for Retailer"
// "Earning Points"

pub fun main() {
    // Get the accounts' public account objects
    let acct1 = getAccount(0x04)

    // Get references to the account's receivers
    // by getting their public capability
    // and borrowing a reference from the capability
    // Note: in "Setup for Customer," if we didn't include FungibleToken.Balance has a interface we could expose, then we wouldn't
    // be able to access it here.
    let acct1ReceiverRef = acct1.getCapability(/public/MainReceiver)!
                          .borrow<&FungibleToken.Vault{FungibleToken.Balance}>()
                          ?? panic("Could not borrow acct1 vault reference")

    // Log the Vault balance of both accounts and ensure they are
    // the correct numbers.
    // Account 0x01 should have 40.
    // Account 0x02 should have 20.
    log("Account 1 Balance")
    log(acct1ReceiverRef.totalBalance)
    log(acct1ReceiverRef.mapTokensToRetailer)

    // Find the public Receiver capability for the user's collection
    let acct1Capability = acct1.getCapability(/public/NFTReceiver)!
                            .borrow<&{NonFungibleToken.NFTReceiver}>()
                            ?? panic("Could not borrow acct1 nft collection reference")

     // Print both collections as arrays of IDs
    log("Account 1 NFTs")
    log(acct1Capability.getItems())
    log("Account 1's UCV")
    log(acct1Capability.getReferenceUCV())
}
