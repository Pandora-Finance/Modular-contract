// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./LibMeta.sol";

contract LibCollectionMeta {

    struct CollectionMeta {
        uint256 collectionId;
        string name;
        uint256 totalTokens;
        LibMeta.TokenMeta[] tokens;
    }

}