// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../NFTFactoryContract.sol";
import "../Libraries/LibBid.sol";
import "../Libraries/LibMeta.sol";

contract NFTBid is NFTFactoryContract {
    event BidOrderReturn(LibBid.BidOrder bid);
    event BidExecuted(uint256 price);
    event AuctionStarted(uint time);

    using Counters for Counters.Counter;

    function Bid(uint256 _saleId) public payable {
        require(_tokenMeta[_saleId].currentOwner != _msgSender());
        require(_tokenMeta[_saleId].status == true);
        require(_tokenMeta[_saleId].bidSale == true);
        require(block.timestamp <= _tokenMeta[_saleId].bidEndTime);
        require(
            _tokenMeta[_saleId].price + ((5 * _tokenMeta[_saleId].price) / 100) <= msg.value
        );
        //  require(_timeOfAuction[_saleId] >= block.timestamp,"Auction Over");

        LibBid.BidOrder memory bid = LibBid.BidOrder(
            Bids[_saleId].length,
            _saleId,
            _tokenMeta[_saleId].currentOwner,
            msg.sender,
            msg.value,
            false
        );
        Bids[_saleId].push(bid);
        _tokenMeta[_saleId].price = msg.value;

        emit BidOrderReturn(bid);
    }

    function SellNFT_byBid(address _collectionAddress, uint256 _tokenId, uint256 _price, uint256 _bidTime)
        public
        onlyOwnerOfToken(_collectionAddress, _tokenId)
        nonReentrant
    {
        require(_collectionAddress != address(0));
         _tokenIdTracker.increment();

        //needs approval on frontend
        ERC721(_collectionAddress).safeTransferFrom(msg.sender, address(this), _tokenId);

        LibMeta.TokenMeta memory meta = LibMeta.TokenMeta(
            _tokenIdTracker.current(),
            _collectionAddress,
            _tokenId,
            _price,
            false,
            true,
            true,
            block.timestamp,
            block.timestamp + _bidTime,
            _msgSender()
        );

         _tokenMeta[_tokenIdTracker.current()] = meta;

        emit TokenMetaReturn(meta, _tokenIdTracker.current());
      
    }

    function executeBidOrder(uint256 _saleId, uint256 _bidOrderID)
        public
        nonReentrant
    {
        require(msg.sender == _tokenMeta[_saleId].currentOwner);
        require(Bids[_saleId][_bidOrderID].withdrawn == false);
        require(_tokenMeta[_saleId].status == true);

         LibShare.Share[] memory royalties;

        if(_tokenMeta[_saleId].collectionAddress == PNDCAddress) {
            royalties = PNDC_ERC721(PNDCAddress).getRoyalties(_tokenMeta[_saleId].tokenId);
        }

        else {
            royalties = TokenERC721(_tokenMeta[_saleId].collectionAddress).getRoyalties(_tokenMeta[_saleId].tokenId);
        }

        _tokenMeta[_saleId].status = false;
        Bids[_saleId][_bidOrderID].withdrawn = true;

        ERC721(_tokenMeta[_saleId].collectionAddress).safeTransferFrom(
            address(this),
            Bids[_saleId][_bidOrderID].buyerAddress,
            _tokenMeta[_saleId].tokenId
        );

         uint sum = Bids[_saleId][_bidOrderID].price;
         uint256 fee = Bids[_saleId][_bidOrderID].price / 100;

        for(uint256 i = 0; i < royalties.length; i ++) {
            uint256 amount = (royalties[i].value * Bids[_saleId][_bidOrderID].price) / 10000;
            address payable receiver = royalties[i].account;
            receiver.transfer(amount);
            sum = sum - amount;
        }

        payable(msg.sender).transfer(sum - fee);
        payable(feeAddress).transfer(fee);

        emit BidExecuted(Bids[_saleId][_bidOrderID].price);
    }

    function withdrawBidMoney(uint256 _saleId, uint256 _bidId) public nonReentrant{
        require(
            msg.sender != _tokenMeta[_saleId].currentOwner
        );
        // BidOrder[] memory bids = Bids[_tokenId];

        require(
            Bids[_saleId][_bidId].buyerAddress == msg.sender
        );
        require(Bids[_saleId][_bidId].withdrawn == false);
        if (payable(msg.sender).send(Bids[_saleId][_bidId].price)) {
            Bids[_saleId][_bidId].withdrawn = true;
        } else {
            revert("No Money left!");
        }
    }
}
