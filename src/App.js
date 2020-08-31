import React, { useState, useEffect } from 'react';
import './App.css'

import * as sdk from "@onflow/sdk"
import * as fcl from "@onflow/fcl"
import * as types from "@onflow/types"

import deployContract from './flow/deploy-contract'
import runTransaction from './flow/run-transaction'

import FTContractURL from './contracts/FTContract.cdc'
import NFTContractURL from './contracts/NFTContract.cdc'
import RewardsContractURL from './contracts/RewardsContract.cdc'

import testTransactionURL from './transactions/test_transaction.cdc'
import setupForCustomerURL from './transactions/setup_for_customer.cdc'
import setupForRetailerURL from './transactions/setup_for_retailer.cdc'
import earningPointsURL from './transactions/earning_points.cdc'
import createRewardURL from './transactions/create_reward.cdc'
import spendPointsURL from './transactions/spend_points.cdc'
import removeRewardURL from './transactions/remove_reward.cdc'
import tradeURL from './transactions/trade.cdc'
import instagramAdURL from './transactions/instagram_ad.cdc'
import setupForNonProfitURL from './transactions/setup_for_nonprofit.cdc'
import stakeNonProfitURL from './transactions/stake_nonprofit.cdc'

import readTokensURL from './scripts/readTokens.cdc'
import readRewardsURL from './scripts/readRewards.cdc'
import readNonProfitTokensURL from './scripts/readNonProfitTokens.cdc'

import { FTAddress, NFTAddress, RewardsAddress, CustomerAddress, RetailerAddress, NonProfitAddress } from './flow/addresses'
import loadCode from './utils/load-code';

// Connection to dev wallet
fcl.config()
  .put("challenge.handshake", "http://localhost:8701/flow/authenticate")

// Runs a script!
const executeSimpleScript = async (a, b) => {
  const response = await fcl.send([
    sdk.script`
      pub fun main(a: Int, b: Int):Int {
        return a + b
      }
    `,
    sdk.args([sdk.arg(a, types.Int), sdk.arg(b, types.Int)]),
  ]);

  return fcl.decode(response);
};

const executeReadTokens = async () => {
  let scriptCode = await loadCode(readTokensURL, {
    query: /(0x01|0x02|0x04)/g,
    "0x01": FTAddress,
    "0x02": NFTAddress,
    "0x04": CustomerAddress
  })

  await fcl.send([
    sdk.script(scriptCode),
  ]);

  console.log("Finished")

}

const executeReadRewards = async () => {
  let scriptCode = await loadCode(readRewardsURL, {
    query: /(0x01|0x02|0x03|0x05)/g,
    "0x01": FTAddress,
    "0x02": NFTAddress,
    "0x03": RewardsAddress,
    "0x05": RetailerAddress
  })

  await fcl.send([
    sdk.script(scriptCode),
  ]);

  console.log("Finished")

}

const executeReadNonProfitNFTs = async () => {
  let scriptCode = await loadCode(readNonProfitTokensURL, {
    query: /(0x02|0x06)/g,
    "0x02": NFTAddress,
    "0x06": NonProfitAddress
  })

  await fcl.send([
    sdk.script(scriptCode),
  ]);

  console.log("Finished")

}

/****** DEPLOY CONTRACTS ******/

const deployFTContract = async () => {
  const tx = await deployContract(FTContractURL)

  fcl.tx(tx).subscribe((txStatus) => {
    if (fcl.tx.isExecuted(txStatus)) {
      console.log("FTContract was deployed");
    }
  });
}

const deployNFTContract = async () => {
  const tx = await deployContract(NFTContractURL)

  fcl.tx(tx).subscribe((txStatus) => {
    if (fcl.tx.isExecuted(txStatus)) {
      console.log("NFTContract was deployed");
    }
  });
}

const deployRewardsContract = async () => {
  const tx = await deployContract(RewardsContractURL)

  fcl.tx(tx).subscribe((txStatus) => {
    if (fcl.tx.isExecuted(txStatus)) {
      console.log("RewardsContract was deployed");
    }
  });
}

/****** TRANSACTIONS ******/

const simpleTransaction = async () => {
  const tx = await runTransaction(testTransactionURL)

  fcl.tx(tx).subscribe((txStatus) => {
    if (fcl.tx.isExecuted(txStatus)) {
      console.log("Transaction was executed");
    }
  });
}

const setupForCustomerTx = async () => {
  const tx = await runTransaction(setupForCustomerURL, {
    query: /(0x01|0x02)/g,
    "0x01": FTAddress,
    "0x02": NFTAddress
  })

  fcl.tx(tx).subscribe((txStatus) => {
    if (fcl.tx.isExecuted(txStatus)) {
      console.log("Customer setup was executed");
    }
  });
}

const setupForRetailerTx = async () => {
  const tx = await runTransaction(setupForRetailerURL, {
    query: /(0x01|0x02|0x03)/g,
    "0x01": FTAddress,
    "0x02": NFTAddress,
    "0x03": RewardsAddress
  })

  fcl.tx(tx).subscribe((txStatus) => {
    if (fcl.tx.isExecuted(txStatus)) {
      console.log("Retailer setup was executed");
    }
  });
}

const earningPointsTx = async (retailer) => {
  const tx = await runTransaction(earningPointsURL, {
    query: /(0x01|0x02|0x04|retailerFromClient)/g,
    "0x01": FTAddress,
    "0x02": NFTAddress,
    "0x04": CustomerAddress,
    "retailerFromClient": `"${retailer}"`
  })

  fcl.tx(tx).subscribe((txStatus) => {
    if (fcl.tx.isExecuted(txStatus)) {
      console.log("Earning points was executed");
    }
  });
}

const createRewardTx = async () => {
  const tx = await runTransaction(createRewardURL, {
    query: /(0x03)/g,
    "0x03": RewardsAddress
  })

  fcl.tx(tx).subscribe((txStatus) => {
    if (fcl.tx.isExecuted(txStatus)) {
      console.log("Create reward was executed");
    }
  });
}

const spendPointsTx = async (boolean) => {
  const tx = await runTransaction(spendPointsURL, {
    query: /(0x01|0x02|0x03|0x05|booleanFromClient)/g,
    "0x01": FTAddress,
    "0x02": NFTAddress,
    "0x03": RewardsAddress,
    "0x05": RetailerAddress,
    "booleanFromClient": boolean
  })

  fcl.tx(tx).subscribe((txStatus) => {
    if (fcl.tx.isExecuted(txStatus)) {
      console.log("Spend points was executed");
    }
  });
}

const removeRewardTx = async () => {
  const tx = await runTransaction(removeRewardURL, {
    query: /(0x03)/g,
    "0x03": RewardsAddress
  })

  fcl.tx(tx).subscribe((txStatus) => {
    if (fcl.tx.isExecuted(txStatus)) {
      console.log("Remove reward was executed");
    }
  });
}

const tradeTx = async () => {
  const tx = await runTransaction(tradeURL, {
    query: /(0x01|0x02|0x03)/g,
    "0x01": FTAddress,
    "0x02": NFTAddress,
    "0x03": RewardsAddress
  })

  fcl.tx(tx).subscribe((txStatus) => {
    if (fcl.tx.isExecuted(txStatus)) {
      console.log("Trade was executed");
    }
  });
}

const instagramADTx = async () => {
  const tx = await runTransaction(instagramAdURL, {
    query: /(0x01|0x02|0x04)/g,
    "0x01": FTAddress,
    "0x02": NFTAddress,
    "0x04": CustomerAddress
  })

  fcl.tx(tx).subscribe((txStatus) => {
    if (fcl.tx.isExecuted(txStatus)) {
      console.log("Trade was executed");
    }
  });
}

const setupNonProfitTx = async () => {
  const tx = await runTransaction(setupForNonProfitURL, {
    query: /(0x02)/g,
    "0x02": NFTAddress
  })

  fcl.tx(tx).subscribe((txStatus) => {
    if (fcl.tx.isExecuted(txStatus)) {
      console.log("Trade was executed");
    }
  });
}

const stakeNonProfitTx = async () => {
  const tx = await runTransaction(stakeNonProfitURL, {
    query: /(0x02|0x06)/g,
    "0x02": NFTAddress,
    "0x06": NonProfitAddress
  })

  fcl.tx(tx).subscribe((txStatus) => {
    if (fcl.tx.isExecuted(txStatus)) {
      console.log("Trade was executed");
    }
  });
}

function App() {
  const [user, setUser] = useState(null)
  const [scriptResult, setScriptResult] = useState(null);
  const [customer, setCustomer] = useState()
  const [retailer, setRetailer] = useState('')
  const [otherRetailer, setOtherRetailer] = useState(false)
  const [color, setColor] = useState('red')

  const handleUser = (user) => {
    console.log(user)
    console.log("Address:", user.addr)
    console.log("CID:", user.cid)

    if (user.cid) {
      setUser(user);
      console.log(user)
    } else {
      setUser(null);
    }
  };

  useEffect(() => {
    if (otherRetailer) setColor('green')
    else setColor('red')
  }, [otherRetailer])

  useEffect(() => {
    // We need to subscribe the user so we can use it to sign transactions and stuff
    return fcl.currentUser().subscribe(handleUser)
  }, [])

  const userLoggedIn = user && !!user.cid

  const callScript = async () => {
    const result = await executeSimpleScript(10, 20);
    setScriptResult(result);
  };

  return (
    <div className="App">
      <button onClick={callScript}>Execute Script</button>
      {scriptResult ? <p className="script-result">Computation Result: {scriptResult}</p> : null}
      {!userLoggedIn ? <button onClick={() => fcl.authenticate()}>Login</button>
        : <div>
          <h1 className="welcome">Welcome, {user.identity.name}</h1>
          <p>Your Address</p><p className="address">{user.addr}</p>
          <h1>Retailer Name:</h1>
          <input type="text" onChange={(e) => setRetailer(e.target.value)} />
          <br />
          <button style={{ backgroundColor: color, outline: 0 }} onClick={() => setOtherRetailer(!otherRetailer)}>Use Other Retailer?</button>
          <br />

          <button onClick={simpleTransaction}>Simple Tx</button>
          <button onClick={deployFTContract}>Deploy FTContract</button>
          <button onClick={deployNFTContract}>Deploy NFTContract</button>
          <button onClick={deployRewardsContract}>Deploy RewardsContract</button>
          <button onClick={setupForCustomerTx}>Setup For Customer</button>
          <button onClick={setupForRetailerTx}>Setup For Retailer</button>
          <button onClick={() => earningPointsTx(user.identity.name)}>Earning Points</button>
          <button onClick={createRewardTx}>Create Reward</button>
          <button onClick={() => spendPointsTx(otherRetailer)}>Spend Points</button>
          <button onClick={removeRewardTx}>Remove Reward</button>
          <button onClick={tradeTx}>Trade</button>
          <button onClick={instagramADTx}>Instagram Ad</button>
          <button onClick={setupNonProfitTx}>Setup For NonProfit</button>
          <button onClick={stakeNonProfitTx}>Stake NonProfit</button>
          <button onClick={executeReadTokens}>Read Tokens</button>
          <button onClick={executeReadRewards}>Read Rewards</button>
          <button onClick={executeReadNonProfitNFTs}>Read NonProfit NFTs</button>
          <button onClick={() => fcl.unauthenticate()}>Logout</button>
        </div>}
    </div >
  );
}

export default App;
