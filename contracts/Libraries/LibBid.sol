// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library LibBid {
    struct BidOrder {
        uint256 tokenId;
        address sellerAddress;
        address buyerAddress;
        uint256 price;
        bool withdrawn;
        uint256 transferCount;
    }

}