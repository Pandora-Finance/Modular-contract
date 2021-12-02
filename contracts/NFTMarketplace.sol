// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./NFTStorage.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

contract NFTMarketplace is
    NFTV1Storage,
    ERC721Upgradeable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable
{
    function initialize() public initializer {
        OwnableUpgradeable.__Ownable_init();
        ReentrancyGuardUpgradeable.__ReentrancyGuard_init();
        ERC721Upgradeable.__ERC721_init("NFTMarketPlace", "NFTMRKT");       
    }

    event TokenMetaReturn(TokenMeta data, uint256 id);

     modifier onlyOwnerOfToken(uint _tokenID) {
      require(msg.sender == ownerOf(_tokenID));
      _;
   }

   modifier tokenExists(uint _tokenID) {
        require(_exists(_tokenID));   
      _;
   }

   
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function fetchNft(uint256 _tokenId) public view returns (TokenMeta memory) {
        return _tokenMeta[_tokenId];
    }

    function BuyNFT(uint256 _tokenId)
        public
        payable
        nonReentrant
    {
        require(msg.sender != address(0) && msg.sender != ownerOf(_tokenId));
        // require(msg.value >= _tokenMeta[_tokenId].price);
        require(_tokenMeta[_tokenId].bidSale == false);
        address tokenSeller = ownerOf(_tokenId);

        TokenMeta memory token = _tokenMeta[_tokenId];
        require(
            msg.value >= token.price,
            "Price >= nft price"
        );
        _transfer(payable(tokenSeller), payable(msg.sender), _tokenId);
        address sendTo = token.currentOwner;
        payable(sendTo).transfer(msg.value);

        token.previousOwner = token.currentOwner;
        token.currentOwner = msg.sender;
        token.numberOfTransfers += 1;
        token.price = msg.value;


        _tokenMeta[_tokenId] = token;
    }
    
    function SellNFT(uint256 _tokenId, uint256 _price) public onlyOwnerOfToken(_tokenId) tokenExists(_tokenId){
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

        _tokenIds+=1;

        _mint(msg.sender, _tokenIds);

        TokenMeta memory meta = TokenMeta(
            _tokenIds,
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
        _tokenMeta[_tokenIds] = meta;

        emit TokenMetaReturn(meta, _tokenIds);

        return _tokenIds;
    }

    
}