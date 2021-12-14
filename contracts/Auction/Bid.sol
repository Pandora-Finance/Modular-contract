// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../NFTFactoryContract.sol";
import "../Libraries/LibBid.sol";
import "../Libraries/LibMeta.sol";

contract NFTBid is NFTFactoryContract {
    event BidOrderReturn(LibBid.BidOrder bid);
    event BidExecuted(uint256 price);
    event AuctionStarted(uint time);

    function Bid(uint256 _tokenId) public payable {
        require(ownerOf(_tokenId) != _msgSender(), "Owners Can't Bid");
        require(_tokenMeta[_tokenId].status == true, "NFT not open for sale");
        require(
            _tokenMeta[_tokenId].price <= msg.value,
            "price >= to selling price"
        );
        require(_timeOfAuction[_tokenId] >= block.timestamp,"Auction Over");

        LibBid.BidOrder memory bid = LibBid.BidOrder(
            _tokenId,
            ownerOf(_tokenId),
            msg.sender,
            msg.value,
            false,
            _tokenMeta[_tokenId].numberOfTransfers
        );
        Bids[_tokenId].push(bid);
        // Bids[_tokenId].push(BidOrder(_tokenId, _sellerAddress, _buyerAddress, _bidPrice));

        emit BidOrderReturn(bid);
    }

    function SellNFT_byBid(uint256 _tokenId, uint256 _price, uint timeOfAuction)
        public
        onlyOwnerOfToken(_tokenId)
    {
        _tokenMeta[_tokenId].directSale = false;
        _tokenMeta[_tokenId].bidSale = true;
        _tokenMeta[_tokenId].price = _price;
        _tokenMeta[_tokenId].status = true;
        _timeOfAuction[_tokenId] = block.timestamp + timeOfAuction ;
        emit AuctionStarted(_timeOfAuction[_tokenId]);

    }

    function executeBidOrder(uint256 _tokenId, uint256 _bidOrderID)
        public
        nonReentrant
        onlyOwnerOfToken(_tokenId)
    {
        safeTransferFrom(
            ownerOf(_tokenId),
            Bids[_tokenId][_bidOrderID].buyerAddress,
            _tokenId
        );
        payable(msg.sender).transfer(Bids[_tokenId][_bidOrderID].price);

        _tokenMeta[_tokenId].previousOwner = _tokenMeta[_tokenId].currentOwner;
        _tokenMeta[_tokenId].currentOwner = Bids[_tokenId][_bidOrderID]
            .buyerAddress;
        _tokenMeta[_tokenId].numberOfTransfers += 1;
        _tokenMeta[_tokenId].price = Bids[_tokenId][_bidOrderID].price;
        _tokenMeta[_tokenId].bidSale = false;
        _tokenMeta[_tokenId].status = false;

        emit BidExecuted(Bids[_tokenId][_bidOrderID].price);
    }

    function withdrawBidMoney(uint256 _tokenId, uint256 _bidId) public {
        require(
            msg.sender != _tokenMeta[_tokenId].currentOwner,
            "Owner can't withdraw"
        );
        // BidOrder[] memory bids = Bids[_tokenId];

        require(
            Bids[_tokenId][_bidId].buyerAddress == msg.sender,
            "Bidder can only withdraw"
        );
        require(Bids[_tokenId][_bidId].withdrawn == false, "Withdrawn");
        if (payable(msg.sender).send(Bids[_tokenId][_bidId].price)) {
            Bids[_tokenId][_bidId].withdrawn = true;
        } else {
            revert("No Money left!");
        }
    }
}
