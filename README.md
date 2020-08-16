# Overview
This is a dapp I built for the Open World Builders Bootcamp during the Summer of 2020. It features a React.js front end that uses a local flow emulator and local dev wallet to communicate with the blockchain. The smart contracts are written in Cadence, the new programming language developed by the Flow team.

## Description
This project simulates NonFungibleTokens in the marketplace through loyalty programs. When a user goes to a retailer and purchases something, they will earn FungibleTokens, or "points," and it will be stored on their account. When a user has accumulated enough points at a specific retailer, they can redeem these points for a NonFungibleToken, minted by the retailer, and it is stored on the user's account. They can then redeem these NFTs, for example a free water bottle at McDonalds, and they will receive the product.

This system also incorporates a community good component where users can trade NonFungibleTokens with each other to maximize profit amongst customers. If one customer favors Burger King over McDonalds while another customer is the opposite, they can trade their points at their least desired retailer for NFTs at their desired retailers to maximize their content. In this way, loyalty is never wasted and can be incorporated wherever you go. Lastly, NFTs can be "donated" to those who may not have the money or ability to purchase food, clothing, etc. NFTs can be donated for 0 points in return to those in need.

## Setup
To setup, go to onflow.org and install the Flow CLI. Run flow emulator start -v to start a local emulator.
Run npm install to install all local depencies and then run npm run dev:wallet to get your local wallet running.
Run npm start to start up the client and have fun!
