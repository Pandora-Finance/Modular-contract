// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library LibMeta1155 {

    struct TokenMeta {
        uint256 saleId;
        address collectionAddress;
        uint256 tokenId;
        uint256 numberOfTokens;
        uint256 price;
        bool directSale;
        bool bidSale;
        bool status;
        uint256 bidStartTime;
        uint256 bidEndTime;
        address mintedBy;
        address currentOwner;
    }

    function transfer(TokenMeta memory token, address _to, uint256 _numberOfTokens ) public pure{
        token.currentOwner = _to;
        token.status = false;
        token.directSale = false ;
        token.bidSale = false ;
        token.numberOfTokens = token.numberOfTokens - _numberOfTokens;
    } 
}