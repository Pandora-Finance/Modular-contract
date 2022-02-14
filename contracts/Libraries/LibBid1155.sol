// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library LibBid1155 {
    struct BidOrder {
        uint256 bidId;
        uint256 numberOfTokens;
        address sellerAddress;
        address buyerAddress;
        uint256 price;
        bool withdrawn;
    }

    struct OrderBook {
        uint256 bidId;
        uint256 numberOfTokens;
        address sellerAddress;
        address buyerAddress;
        uint256 price;
        bool withdrawn;
    }
}