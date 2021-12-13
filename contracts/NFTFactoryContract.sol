// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./NFTStorage.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol";
import "./TokenERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTFactoryContract is
    ERC721Upgradeable,
    NFTV1Storage,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable,
    ERC721HolderUpgradeable
{
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdTracker;

    address contractAddress = address(this);

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

    modifier onlyOwnerOfCollectionToken(address _collectionAddress, uint256 _tokenId) {
        require(msg.sender == TokenERC721(_collectionAddress).ownerOf(_tokenId));
        _;
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal virtual override
    {
        super._beforeTokenTransfer(from, to, tokenId);
        LibMeta.transfer(_tokenMeta[tokenId], to);        
    }

// Change in BuyNFT LibMeta Function

    function BuyNFT(uint256 _tokenId) public payable nonReentrant {
        LibMeta.TokenMeta memory meta = _tokenMeta[_tokenId];
        require(msg.sender != address(0) && msg.sender != meta.currentOwner);
        require(meta.bidSale == false);
        require(msg.value >= meta.price, "Price >= nft price");

        payable(meta.currentOwner).transfer(msg.value);
        if(meta.collectionAddress == contractAddress) {
            _transfer(contractAddress, payable(msg.sender), _tokenId);
        }
        else {
            IERC721(meta.collectionAddress).safeTransferFrom(contractAddress, payable(msg.sender), _tokenId);
        }
        LibMeta.transfer(_tokenMeta[_tokenId],msg.sender);

    }

    function SellNFT(uint256 _tokenId, uint256 _price)
        public
        onlyOwnerOfToken(_tokenId)
    {   
        require(_price > 0);

        //Needs approval on frontend
        safeTransferFrom(msg.sender, contractAddress, _tokenId);

        _tokenMeta[_tokenId].bidSale = false;
        _tokenMeta[_tokenId].directSale = true;
        _tokenMeta[_tokenId].price = _price;
    }

    function sellNFT(address _collectionAddress, uint256 _tokenId, uint256 _price) 
    public 
    onlyOwnerOfCollectionToken(_collectionAddress, _tokenId)
    {
        _tokenIdTracker.increment();

        string memory tokenUri = TokenERC721(_collectionAddress).tokenURI(_tokenId);

        //needs approval on frontend
        TokenERC721(_collectionAddress).safeTransferFrom(msg.sender, contractAddress, _tokenId);

        LibMeta.TokenMeta memory meta = LibMeta.TokenMeta(
            _collectionAddress,
            _tokenId,
            _price,
            "",
            tokenUri,
            true,
            false,
            false,
            TokenERC721(_collectionAddress).ownerOf(_tokenId),
            _msgSender(),
            _msgSender(),
            0
        );

         _tokenMeta[_tokenIdTracker.current()] = meta;

        emit TokenMetaReturn(meta, _tokenIdTracker.current());

    }

    function mintNFT(
        string memory _tokenURI,
        string memory _name
    ) public returns (uint256) {

        _tokenIdTracker.increment();

        _mint(msg.sender, _tokenIdTracker.current());

        LibMeta.TokenMeta memory meta = LibMeta.TokenMeta(
            contractAddress,
            _tokenIdTracker.current(),
            0,
            _name,
            _tokenURI,
            false,
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

}
