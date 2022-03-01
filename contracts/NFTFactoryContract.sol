// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./NFTStorage.sol";
import "./Libraries/LibShare.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./TokenERC721.sol";
import "./PNDC_ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTFactoryContract is
  OwnableUpgradeable,
  ReentrancyGuardUpgradeable,
  ERC721HolderUpgradeable,
  NFTV1Storage
{
  using Counters for Counters.Counter;


    event TokenMetaReturn(LibMeta.TokenMeta data, uint256 id);

    modifier onlyOwnerOfToken(address _collectionAddress, uint256 _tokenId) {
        require(msg.sender == ERC721(_collectionAddress).ownerOf(_tokenId),"1");
        _;
    }

  // Change in BuyNFT LibMeta Function

  function BuyNFT(uint256 _saleId) external payable nonReentrant {
    LibMeta.TokenMeta memory meta = _tokenMeta[_saleId];

    LibShare.Share[] memory royalties;

    if (_tokenMeta[_saleId].collectionAddress == PNDCAddress) {
      royalties = PNDC_ERC721(PNDCAddress).getRoyalties(
        _tokenMeta[_saleId].tokenId
      );
    } else {
      royalties = TokenERC721(_tokenMeta[_saleId].collectionAddress)
        .getRoyalties(_tokenMeta[_saleId].tokenId);
    }

    require(meta.status,"2");
    require(msg.sender != address(0) && msg.sender != meta.currentOwner,"3");
    require(!meta.bidSale,"4");
    require(msg.value >= meta.price,"5");

    LibMeta.TokenMeta memory tok = LibMeta.transfer(
      _tokenMeta[_saleId],
      msg.sender
    );
    _tokenMeta[_saleId] = tok;

    uint256 sum = msg.value;
    uint256 val = msg.value;
    uint256 fee = msg.value / 100;

    for (uint256 i = 0; i < royalties.length; i++) {
      uint256 amount = (royalties[i].value * val) / 10000;
      address payable receiver = royalties[i].account;
      receiver.call{ value: amount }("");
      sum = sum - amount;
    }

    payable(meta.currentOwner).call{ value: (sum - fee) }("");
    payable(feeAddress).call{ value: fee }("");
    ERC721(meta.collectionAddress).safeTransferFrom(
      address(this),
      msg.sender,
      meta.tokenId
    );
  }

  function sellNFT(
    address _collectionAddress,
    uint256 _tokenId,
    uint256 _price
  ) external onlyOwnerOfToken(_collectionAddress, _tokenId) nonReentrant {
    _tokenIdTracker.increment();

    //needs approval on frontend
    ERC721(_collectionAddress).safeTransferFrom(
      msg.sender,
      address(this),
      _tokenId
    );

    LibMeta.TokenMeta memory meta = LibMeta.TokenMeta(
      _tokenIdTracker.current(),
      _collectionAddress,
      _tokenId,
      _price,
      true,
      false,
      true,
      0,
      0,
      _msgSender()
    );

    _tokenMeta[_tokenIdTracker.current()] = meta;

    emit TokenMetaReturn(meta, _tokenIdTracker.current());
  }

  function cancelSale(uint256 _saleId) external nonReentrant {
    require(msg.sender == _tokenMeta[_saleId].currentOwner,"1");
    require(_tokenMeta[_saleId].status == true,"2");

    _tokenMeta[_saleId].status = false;
    ERC721(_tokenMeta[_saleId].collectionAddress).safeTransferFrom(
      address(this),
      _tokenMeta[_saleId].currentOwner,
      _tokenMeta[_saleId].tokenId
    );
  }
}
