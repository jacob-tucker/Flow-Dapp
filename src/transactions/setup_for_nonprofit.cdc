// setup_for_nonprofit.cdc

import NonFungibleToken from 0x02

// This transaction sets up a new non-profit for the marketplace
// by creating an empty NFT Collection for the non-profit
// so they can eventually receive NFTs from the customers who stake
// their campaigns

// SIGNED BY: NON-PROFIT
transaction {
  prepare(acct: AuthAccount) {
    // store an empty NFT Collection in account storage so the non-profit can later receive NFTs
    acct.save<@NonFungibleToken.Collection>(<-NonFungibleToken.createEmptyCollection(), to: /storage/NFTCollection)

    // publish a capability to the Collection in storage so it can be deposited into
    acct.link<&{NonFungibleToken.NFTReceiver}>(/public/NFTReceiver, target: /storage/NFTCollection)

    log("Created a new NFT empty collection and published a reference")
  }
}