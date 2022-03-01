# Pandora Protocol Contracts

## Features

- Mint NFT items
- Sell NFT's
- Auction NFT's
- Create NFT collections
- TBD (coming many more)

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

## Error Table        

The table below lists all possible reasons for errors in a contract call that mints, bids, buy, sell, withdraw bid or cancel a sale.

| No   |      Error      |  Reason |
|:----------:|:-------------|:------|
| 1 | Not an owner of token | Should be an owner of token |
| 2 | Token not for sale | Put token up for sale |
| 3 | Buyer is owner of token | Buyer of token can't be the owner of token |
| 4 | Token is not put on bid Sale | Put token on bid sale |
| 5 | Price entered is lower than base price of token | Provide price greater than the base price of token |
| 6 | Buyer is an owner of token | Buyer of token can't be an owner of token |
| 7 | Quantity greater than number of tokens | Number of tokens should be greater or equal to quantity |
| 8 | Quantity less than (price x quantity)) | Quantity should be greater or equal to (price x quantity)) |
| 9 | Collection Address is zero address | Collection Address should not be zero address |
| 10 | Minting more than 15 Nfts | Minting more than 15 Nfts are not allowed |
| 11 | URI array & totalNFT count mismatch | URI array length should be equal to _totalNFT |
| 12 | Royalities array length is greater than 10 | Royalities array length should be less than or equal to 10 |
| 13 | Royalty recipient is not present | Royalty recipient should be present |
| 14 | Royalty value is less or equal to 0 | Royalty value should be greater than 0 |
| 15 | Sum of Royalties > 100% | Sum of Royalties should be < 100% |
| 16 | Not a valid address | Provide a valid address |
| 17 | Not a valid fee address | Provide a valid fee address |
| 18 | Bid end time exceeded | Timestamp greater than bid end time |
| 19 | Bid price is less than base price | Bid price should be minimum 5% more than the base price |
| 20 | Bid withdrawn for order Id | Bid should not be withdrawn to execute order for particular order Id |
| 21 | Address is not a bidder address | Bidder Address is mismatched |
| 22 | Price for each quantity is less than base price of single quantity | Price for each quantity should be greater or equal to the base price of single quantity |
        
We are in the phase of auditing. Please consider it as beta version.