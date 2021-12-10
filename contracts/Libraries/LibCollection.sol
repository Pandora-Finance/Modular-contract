// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./LibShare.sol";

library LibCollection {

    struct CollectionMeta {
        uint256 id;
        string name;
        string symbol;
        address contractAddress;
        address owner;
        string description;
    }

    // struct CollectionToken {
    //    uint256 id;
    //     uint256 price;
    //     string name;
    //     string uri;
    //     bool directSale;
    //     bool bidSale;
    //     bool status;
    //     address mintedBy;
    //     address currentOwner;
    //     uint256 numberOfTransfers;
    //     uint256 collectionId;
    //     address collectionAddress;
    // }
}