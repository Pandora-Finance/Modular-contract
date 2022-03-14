// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../NFTFactoryContract1155.sol";

contract NFTBid1155 is NFTFactoryContract1155 {
    event BidOrderReturn(LibBid1155.BidOrder bid);
    event BidExecuted(uint256 price);
    event AuctionStarted(uint time);

    using Counters for Counters.Counter;

    function Bid(uint256 _saleId, uint256 _amount) external payable {
        require(_tokenMeta[_saleId].currentOwner != msg.sender,"3");
        require(_tokenMeta[_saleId].status == true,"2");
        require(_tokenMeta[_saleId].bidSale == true,"4");
        require(msg.value % _amount == 0);
        require(msg.value / _amount >= _tokenMeta[_saleId].price,"22");
        require(_tokenMeta[_saleId].numberOfTokens >= _amount,"7");

        LibBid1155.BidOrder memory bid = LibBid1155.BidOrder(
            _saleId,
            _amount,
            _tokenMeta[_saleId].currentOwner,
            msg.sender,
            msg.value,
            false
        );
        Bids[_saleId].push(bid);

        emit BidOrderReturn(bid);
    }

    function SellNFT_byBid(address _collectionAddress, uint256 _tokenId, uint256 _price, uint256 _amount)
        external
        nonReentrant
    {
        require(_collectionAddress != address(0));
        require(_price > 0);
        require(_amount > 0);
        uint256 bal = ERC1155(_collectionAddress).balanceOf(msg.sender, _tokenId);
        require(bal >= _amount,"7");

         _tokenIdTracker.increment();

        //needs approval on frontend
        ERC1155(_collectionAddress).safeTransferFrom(msg.sender, address(this), _tokenId, _amount, "");

        LibMeta1155.TokenMeta memory meta = LibMeta1155.TokenMeta(
            _collectionAddress,
            _tokenId,
            _amount,
            _price,
            false,
            true,
            true,
            msg.sender
        );

         _tokenMeta[_tokenIdTracker.current()] = meta;

        emit TokenMetaReturn(meta, _tokenIdTracker.current());
      
    }

    function executeBidOrder(uint256 _saleId, uint256 _bidOrderID)
        external
        nonReentrant
    {   
        LibBid1155.BidOrder memory bids = Bids[_saleId][_bidOrderID];
        require(msg.sender == _tokenMeta[_saleId].currentOwner,"1");
        require(bids.withdrawn == false,"20");
        require(_tokenMeta[_saleId].status == true,"2");
        require(_tokenMeta[_saleId].numberOfTokens >= bids.numberOfTokens,"7");

        LibShare.Share[] memory royalties = LibRoyalty.retrieveRoyalty(
            _tokenMeta[_saleId].collectionAddress,
            PNDC1155Address,
            _tokenMeta[_saleId].tokenId
        );

        LibMeta1155.transfer(_tokenMeta[_saleId], bids.numberOfTokens);
        bids.withdrawn = true;

        ERC1155(_tokenMeta[_saleId].collectionAddress).safeTransferFrom(
            address(this),
            bids.buyerAddress,
            _tokenMeta[_saleId].tokenId,
            bids.numberOfTokens,
            ""
        );

        uint sum = bids.price;
        uint fee = bids.price / 100;

        for(uint256 i = 0; i < royalties.length; i ++) {
            uint256 amount = (royalties[i].value * bids.price) / 10000;
            royalties[i].account.call{value: amount}("");
            sum = sum - amount;
        } 

        payable(msg.sender).call{value: (sum - fee)}("");
        payable(feeAddress).call{value: fee}("");

        emit BidExecuted(bids.price);
    }

    function withdrawBidMoney(uint256 _saleId, uint256 _bidId) external nonReentrant{
        LibBid1155.BidOrder memory bids = Bids[_saleId][_bidId];
        require(
            bids.buyerAddress == msg.sender,
            "21"
        );
        require(bids.withdrawn == false,"20");
        (bool success, ) = payable(msg.sender).call{
            value: bids.price
        }("");
        if (success) {
            bids.withdrawn = true;
        } else {
            revert("No Money left!");
        }
    }
}