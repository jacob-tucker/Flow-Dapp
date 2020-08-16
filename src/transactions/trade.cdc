// trade.cdc
import FungibleToken from 0x01
import NonFungibleToken from 0x02
import RewardsContract from 0x03


// This transaction trades an NFT for a certain amount of fungible tokens. One user receives an NFT 
// and one user receives a certain amount of fungible tokens.
transaction {

    let account1NFTGive: &NonFungibleToken.Collection
    let transferingNFT: @NonFungibleToken.NFT
    let account1VaultTake: &FungibleToken.Vault{FungibleToken.Receiver}
    prepare(acct: AuthAccount) {
        // Borrow the NFT Collection for account 1. Notice we do not use
        // the NFTReceiver interface because that would restrict us from withdrawing the NFT
        self.account1NFTGive = acct.borrow<&NonFungibleToken.Collection>(from: /storage/NFTCollection)
                                ?? panic("Could not borrow account 1's NFT Collection")

        // Store the NFT that will be traded
        self.transferingNFT <- self.account1NFTGive.withdraw(withdrawItem: "McDonalds:Water Bottle")

        // Borrows a reference by using a capability to account 1's fungible token vault,
        // using the Receiver interface because they will be receiving fungible tokens
        self.account1VaultTake = acct.getCapability(/public/MainReceiver)!
                                    .borrow<&FungibleToken.Vault{FungibleToken.Receiver}>()
                                    ?? panic("Could not borrow account 1's vault reference")

    }

    execute {
        // Get the 2nd account
        let account2 = getAccount(0x02)
        // Borrow a reference to account 2's fungible token vault, using the Provider interface
        // because they will be giving the fungible tokens
        let account2VaultGive = account2.getCapability(/public/MainReceiver)!
                                        .borrow<&FungibleToken.Vault{FungibleToken.Provider}>()
                                        ?? panic("Could not borrow account 2's vault reference") 
        // Removes the fungible token's from account 2 and stores them in a vault
        let removedTokensVault <- account2VaultGive.withdraw(amount: UFix64(10))

        // Deposits the vault into account 1
        self.account1VaultTake.deposit(from: <-removedTokensVault)

        // Gets a reference to account 2's NFT Collection because they will be
        // receiving NFTs
        let account2NFTTake = account2.getCapability(/public/NFTReceiver)!
                                .borrow<&{NonFungibleToken.NFTReceiver}>()
                                ?? panic("Could not borrow account 2's NFT Collection")

        // Deposits the NFT into account 2
        account2NFTTake.deposit(token: <-self.transferingNFT)
    }
}