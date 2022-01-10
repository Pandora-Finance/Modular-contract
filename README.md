# Pandora Protocol
## 
##
##
## NFTStorage/NFTStorage1155

- Contracts that store data of sales, collections, and important mappings.

## PNDC_ERC721/PNDC_ERC1155

- Contracts for minting of nft's
- Also stores royalties of the nft's.

## TokenERC721/TokenERC1155

- The boilerplate code for all the collection contracts that will be deployed
- One can mint their collection nft's
- Also store collection royalties and individual nft royalties

## NFTFactory/NFTFActory1155

- The main contracts where one can buy and sell their nft's from various contract addresses
- Inherits NFTStorage/NFTStorage1155
- On sale, sale metadata is collected and stored in NFTStorage/NFTStorage1155

## Bid/Bid1155

- Inherits NFTFactory/NFTFactory1155
- Provides auction functionality for the nft's

## TokenFactory/TokenFActory1155

- Inherits Bid/Bid1155
- Provide functions for a user to create collections and store the collection details in NFTStorage/NFTStorage1155