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
        setBaseURI(
            ""
        );
    }

    event TokenMetaReturn(TokenMeta data, uint256 id);

    function fetchBaseURI() internal view virtual returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory _newBaseURI) public virtual onlyOwner {
        baseURI = _newBaseURI;
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
            "Price should be greater than or equal to nft price"
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
    
    function SellNFT(uint256 _tokenId, uint256 _price) public {
        require(_exists(_tokenId));
        require(ownerOf(_tokenId) == _msgSender());

        _tokenMeta[_tokenId].bidSale = false;
        _tokenMeta[_tokenId].directSale = true;
        _tokenMeta[_tokenId].price = _price;
    }

     function _setTokenMeta(uint256 _tokenId, TokenMeta memory _meta) private {
        require(_exists(_tokenId));
        require(ownerOf(_tokenId) == _msgSender());
        _tokenMeta[_tokenId] = _meta;
    }

     function mintNFT(
        string memory _tokenURI,
        string memory _name,
        uint256 _price
    ) public returns (uint256) {
        require(_price > 0);

        _tokenIds+=1;

        uint256 newItemId = _tokenIds;
        _mint(msg.sender, newItemId);

        TokenMeta memory meta = TokenMeta(
            newItemId,
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
        _setTokenMeta(newItemId, meta);

        emit TokenMetaReturn(meta, newItemId);

        return newItemId;
    }

    
}