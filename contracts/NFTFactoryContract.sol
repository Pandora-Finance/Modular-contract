// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./NFTStorage.sol";
import "./Libraries/LibMeta.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTFactoryContract is
    NFTV1Storage,
    ERC721Upgradeable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable
{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdTracker;

    function initialize() public initializer {
        OwnableUpgradeable.__Ownable_init();
        ReentrancyGuardUpgradeable.__ReentrancyGuard_init();
        ERC721Upgradeable.__ERC721_init("NFTFactoryContract", "NFTMRKT");
    }

    event TokenMetaReturn(LibMeta.TokenMeta data, uint256 id);
    event BatchMint(uint256 _totalNft, string msg);

    modifier onlyOwnerOfToken(uint256 _tokenID) {
        require(msg.sender == ownerOf(_tokenID));
        _;
    }

    modifier tokenExists(uint256 _tokenID) {
        require(_exists(_tokenID));
        _;
    }

    function BuyNFT(uint256 _tokenId) public payable nonReentrant {
        require(msg.sender != address(0) && msg.sender != ownerOf(_tokenId));
        require(_tokenMeta[_tokenId].bidSale == false);
        require(msg.value >= _tokenMeta[_tokenId].price, "Price >= nft price");

        payable(ownerOf(_tokenId)).transfer(msg.value);
        _transfer(ownerOf(_tokenId), payable(msg.sender), _tokenId);
        LibMeta.transfer(_tokenMeta[_tokenId]);
    }

    function SellNFT(uint256 _tokenId, uint256 _price)
        public
        onlyOwnerOfToken(_tokenId)
        tokenExists(_tokenId)
    {
        _tokenMeta[_tokenId].bidSale = false;
        _tokenMeta[_tokenId].directSale = true;
        _tokenMeta[_tokenId].price = _price;
    }

    function mintNFT(
        string memory _tokenURI,
        string memory _name,
        uint256 _price
    ) public returns (uint256) {
        require(_price > 0);

        _tokenIdTracker.increment();

        _mint(msg.sender, _tokenIdTracker.current());

        LibMeta.TokenMeta memory meta = LibMeta.TokenMeta(
            _tokenIdTracker.current(),
            _price,
            _name,
            _tokenURI,
            true,
            false,
            false,
            _msgSender(),
            _msgSender(),
            _msgSender(),
            0
        );
        _tokenMeta[_tokenIdTracker.current()] = meta;

        emit TokenMetaReturn(meta, _tokenIdTracker.current());

        return _tokenIdTracker.current();
    }

    function batchMint(uint _totalNFT, string[] memory _name, string[] memory _tokenURI, uint[] memory _price) external nonReentrant returns (bool) {
        require(_totalNFT <= 15, "15 or less allowed");
        require(_name.length == _tokenURI.length, "Total Uri and TotalNft does not match");

         for(uint i = 0; i< _totalNFT; i++) {
            mintNFT(_tokenURI[i], _name[i], _price[i]);
        }
        emit BatchMint(_totalNFT, "Batch mint success");
        return true;
    }
}
