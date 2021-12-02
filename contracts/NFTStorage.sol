// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract NFTAdminStorage {

    address public admin;
    address public pendingAdmin;
    address public NFTImplementation;
    address public pendingNFTImplementation;

}

contract NFTV1Storage is NFTAdminStorage {

    struct TokenMeta {
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

    mapping(uint256 => TokenMeta) public _tokenMeta;  
   

    uint public _tokenIds;

    struct BidOrder {
        uint256 tokenId;
        address sellerAddress;
        address buyerAddress;
        uint256 price;
        bool withdrawn;
    }

    mapping(uint256 => BidOrder[]) public Bids;

    string baseURI;
}

