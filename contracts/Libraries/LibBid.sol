// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library LibBid {
    struct BidOrder {
        uint256 saleId;
        address sellerAddress;
        address buyerAddress;
        uint256 price;
        bool withdrawn;
    }

}