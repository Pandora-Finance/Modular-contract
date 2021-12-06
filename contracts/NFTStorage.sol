// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Libraries/LibMeta.sol";
import "./Libraries/LibBid.sol";

contract NFTV1Storage {

    mapping(uint256 => LibMeta.TokenMeta) public _tokenMeta;
    uint public _tokenIds;
    mapping(uint256 => LibBid.BidOrder[]) public Bids;
    string baseURI;
    
}

