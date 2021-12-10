// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library LibMeta {

    struct TokenMeta {
        address collectionAddress;
        uint256 id;
        uint256 price;
        string name;
        string uri;
        bool directSale;
        bool bidSale;
        bool status;
        address mintedBy;
        address currentOwner;
        address previousOwner;
        uint256 numberOfTransfers;
    }

    function transfer(TokenMeta memory token, address _to ) public pure{
        token.previousOwner = token.currentOwner;
        token.currentOwner = _to;
        token.numberOfTransfers += 1;
        token.directSale = false ;
        token.bidSale = false ;
    } 
}