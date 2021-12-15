# Pandora Protocol
## 
##
##
## NFTStorage

- Contract stores data of sales, collections, and important mappings.

## PNDC_ERC721

- Contract for minting of single nft's
- Also stores royalties of the nft's.

## TokenERC721

- The boilerplate code for all the collection contract that will be deployed
- One can mint their collection nft's
- Also stores collection royalties and individual nft royalties

## NFTFactory

- The main contract where one can buy and sell their nft's from various contract addresses
- Inherits NFTStorage
- On sale, sale metadata is collected and stored in NFTStorage

## Bid

- Inherits NFTFactory
- Provides auction functionality for the nft's

## TokenFactory

- Inherits Bid
- Provides functions for a user to create a collection and stores the collection details in NFTStorage