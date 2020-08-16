// NFTContract.cdc
//
// This is a complete version of the NonFungibleToken contract
// that includes withdraw and deposit functionality, as well as a
// collection resource that can be used to bundle NFTs together.
//
// It also includes a definition for the Minter resource,
// which can be used by admins to mint new NFTs.
//
// Learn more about non-fungible tokens in this tutorial: https://docs.onflow.org/docs/non-fungible-tokens

pub contract NonFungibleToken {

    // Declare the NFT resource type
    pub resource NFT {
        // The unique ID that differentiates each NFT
        pub let id: UInt64
        // The retailer that this NFT was minted from
        pub let retailer: String
        // The item that this NFT represents
        pub let item: String

        // Initialize both fields in the init function
        init(initID: UInt64, initRetailer: String, initItem: String) {
            self.id = initID
            self.retailer = initRetailer
            self.item = initRetailer.concat(":").concat(initItem)
        }
    }

    // We define this interface purely as a way to allow users
    // to create public, restricted references to their NFT Collection.
    // They would use this to only expose the deposit, getIDs,
    // and idExists fields in their Collection
    pub resource interface NFTReceiver {
        pub fun deposit(token: @NFT)

        pub fun getItems(): [String]

        pub fun itemExists(item: String): Bool
    }

    // The definition of the Collection resource that
    // holds the NFTs that a user owns
    pub resource Collection: NFTReceiver {
        // dictionary of NFT conforming tokens
        // NFT is a resource type with an `UInt64` ID field
        pub var ownedNFTs: @{String: NFT}

        // Initialize the NFTs field to an empty collection
        init () {
            self.ownedNFTs <- {}
        }

        // withdraw 
        //
        // Function that removes an NFT from the collection 
        // and moves it to the calling context
        pub fun withdraw(withdrawItem: String): @NFT {
            // If the NFT isn't found, the transaction panics and reverts
            let token <- self.ownedNFTs.remove(key: withdrawItem)!

            return <-token
            
        }

        // deposit 
        //
        // Function that takes a NFT as an argument and 
        // adds it to the collections dictionary
        pub fun deposit(token: @NFT) {
            // first remove the old token by indexing the dictionary, THEN put the new token there, and then destroy
            // the old token.
            let oldToken <- self.ownedNFTs[token.item] <- token
            destroy oldToken
        }

        // idExists checks to see if a NFT 
        // with the given ID exists in the collection
        pub fun itemExists(item: String): Bool {
            return self.ownedNFTs[item] != nil
        }

        // getIDs returns an array of the IDs that are in the collection
        pub fun getItems(): [String] {
            return self.ownedNFTs.keys
        }

        destroy() {
            destroy self.ownedNFTs
        }
    }

    // creates a new empty Collection resource and returns it 
    pub fun createEmptyCollection(): @Collection {
        return <- create Collection()
    }

    // NFTMinter
    //
    // Resource that would be owned by an admin or by a smart contract 
    // that allows them to mint new NFTs when needed
    pub resource NFTMinter {

        // the ID that is used to mint NFTs
        // it is onlt incremented so that NFT ids remain
        // unique. It also keeps track of the total number of NFTs
        // in existence
        pub var idCount: UInt64

        init() {
            self.idCount = 1
        }

        // mintNFT 
        //
        // Function that mints a new NFT with a new ID
        // and deposits it in the recipients collection 
        // using their collection reference
        pub fun mintNFT(recipient: &AnyResource{NFTReceiver}, retailer: String, item: String) {

            // create a new NFT
            var newNFT <- create NFT(initID: self.idCount, initRetailer: retailer, initItem: item)
            
            // deposit it in the recipient's account using their reference
            recipient.deposit(token: <-newNFT)

            // change the id so that each ID is unique
            self.idCount = self.idCount + UInt64(1)
        }
    }

    // A function for retailers that allows them to use this minter to mint NFTs and give them to
    // their customers
    pub fun createNFTMinter(): @NFTMinter {
        return <- create NFTMinter()
    }

	init() {

	}
}
 