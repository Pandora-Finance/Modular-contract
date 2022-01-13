# Pandora Protocol Contracts

## Features

- Mint NFT items
- Sell NFT's
- Auction NFT's
- Create NFT collections

## Installation

- Clone the repository
- Install the dependancies 

        npm install

## Compile Contracts

- Run the truffle compilation 

        truffle compile --all

## Test Contracts

- Run the local truffle develpment environment and run the test cases within the environment

        truffle develop
        test

## Deploy contracts to the BSC testnet

- Create a .env file storing a metamask private key and bscscan api(To verify contracts after deployment)
- the .env stucture should be as follows:

        PK=<Private Key>
        BSC_API=<API key>

- Then run the truffle migration command

        truffle migrate --reset --network testnet