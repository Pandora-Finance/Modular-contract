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

}