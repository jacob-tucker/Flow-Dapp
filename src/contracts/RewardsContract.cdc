
// Rewards.cdc

// This contract provides the definition for the Rewards list for
// each retailer.
pub contract RewardsContract {

    // A resource that can be given to each retailer so they can make
    // a list of rewards for a certain amount of points
    pub resource Rewards {
        // A dictionary that maps the name of the rewards to the amount of
        // points it costs.
        pub let rewards: {String: UFix64}
        
        // Creates a new reward
        pub fun createReward(name: String, points: UFix64) {
            self.rewards[name] = points
        }

        pub fun removeReward(name: String) {
            self.rewards.remove(key: name)
        }

        // Returns the list of rewards for each retailer so customers can
        // see what their options are
        pub fun getRewards(): {String: UFix64} {
            return self.rewards
        }

        pub fun itemExists(name: String): Bool {
            return self.rewards.keys.contains(name)
        }

        pub fun costOfItem(name: String): UFix64 {
            return self.rewards[name]!
        }

        init() {
            self.rewards = {}
        }
    }
    
    pub fun createEmptyRewards(): @Rewards {
      return <- create Rewards()
    }

    init() {

    }
}
 