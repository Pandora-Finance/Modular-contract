// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Libraries/LibMeta1155.sol";
import "./Libraries/LibBid1155.sol";
import "./Libraries/LibCollection1155.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTV1Storage1155 {

    mapping(uint256 => LibMeta1155.TokenMeta) public _tokenMeta;
    uint public _tokenIds;
    mapping(uint256 => LibBid1155.BidOrder[]) public Bids;
    string baseURI;
    mapping(uint256 => LibCollection1155.CollectionMeta) public collections;
    mapping(address => uint256[]) public ownerToCollections;
    mapping(address => address) public collectionToOwner;
    Counters.Counter public collectionIdTracker;
    Counters.Counter internal _tokenIdTracker;
    address internal PNDC1155Address;
}