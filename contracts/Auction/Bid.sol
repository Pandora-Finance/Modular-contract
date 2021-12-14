// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../NFTFactoryContract.sol";
import "../Libraries/LibBid.sol";
import "../Libraries/LibMeta.sol";

contract NFTBid is NFTFactoryContract {
    event BidOrderReturn(LibBid.BidOrder bid);
    event BidExecuted(uint256 price);

    function Bid(uint256 _saleId) public payable {
        require(_tokenMeta[_saleId].currentOwner != _msgSender(), "Owners Can't Bid");
        require(_tokenMeta[_saleId].status == true, "NFT not open for sale");
        require(
            _tokenMeta[_saleId].price <= msg.value,
            "price >= to selling price"
        );

        LibBid.BidOrder memory bid = LibBid.BidOrder(
            _saleId,
            _tokenMeta[_saleId].currentOwner,
            msg.sender,
            msg.value,
            false
        );
        Bids[_saleId].push(bid);
        // Bids[_tokenId].push(BidOrder(_tokenId, _sellerAddress, _buyerAddress, _bidPrice));

        emit BidOrderReturn(bid);
    }

    function SellNFT_byBid(uint256 _saleId, uint256 _price)
        public
    {
        require(msg.sender == _tokenMeta[_saleId].currentOwner);

        _tokenMeta[_saleId].directSale = false;
        _tokenMeta[_saleId].bidSale = true;
        _tokenMeta[_saleId].price = _price;
        _tokenMeta[_saleId].status = true;
    }

    function executeBidOrder(uint256 _saleId, uint256 _bidOrderID)
        public
        nonReentrant
    {
         require(msg.sender == _tokenMeta[_saleId].currentOwner);

        ERC721(_tokenMeta[_saleId].collectionAddress).safeTransferFrom(
            address(this),
            Bids[_saleId][_bidOrderID].buyerAddress,
            _tokenMeta[_saleId].tokenId
        );
        payable(msg.sender).transfer(Bids[_saleId][_bidOrderID].price);

        _tokenMeta[_saleId].currentOwner = Bids[_saleId][_bidOrderID]
            .buyerAddress;
        _tokenMeta[_saleId].price = Bids[_saleId][_bidOrderID].price;
        _tokenMeta[_saleId].bidSale = false;
        _tokenMeta[_saleId].status = false;

        emit BidExecuted(Bids[_saleId][_bidOrderID].price);
    }

    function withdrawBidMoney(uint256 _saleId, uint256 _bidId) public {
        require(
            msg.sender != _tokenMeta[_saleId].currentOwner,
            "Owner can't withdraw"
        );
        // BidOrder[] memory bids = Bids[_tokenId];

        require(
            Bids[_saleId][_bidId].buyerAddress == msg.sender,
            "Bidder can only withdraw"
        );
        require(Bids[_saleId][_bidId].withdrawn == false, "Withdrawn");
        if (payable(msg.sender).send(Bids[_saleId][_bidId].price)) {
            Bids[_saleId][_bidId].withdrawn = true;
        } else {
            revert("No Money left!");
        }
    }
}
