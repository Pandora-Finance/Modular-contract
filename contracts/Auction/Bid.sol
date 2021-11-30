// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../NFTMarketplace.sol";

contract NFTBid is
    NFTMarketplace
{

    event BidOrderReturn(BidOrder bid);
    event BidExecuted(uint256 price);
    
    function Bid(uint256 _tokenId) public payable tokenExists(_tokenId){        
        require(ownerOf(_tokenId) != _msgSender(), "Owners Can't Bid");
        require(
            _tokenMeta[_tokenId].status == true,
            "NFT not open for sale"
        );
        require(
            _tokenMeta[_tokenId].price <= msg.value,
            "price >= to selling price"
        );

        BidOrder memory bid = BidOrder(
            _tokenId,
            ownerOf(_tokenId),
            msg.sender,
            msg.value,
            false
        );
        Bids[_tokenId].push(bid);
        // Bids[_tokenId].push(BidOrder(_tokenId, _sellerAddress, _buyerAddress, _bidPrice));

        emit BidOrderReturn(bid);
    }
    


     function SellNFT_byBid(uint256 _tokenId, uint256 _price) public onlyOwnerOfToken(_tokenId) tokenExists(_tokenId) {
       
        _tokenMeta[_tokenId].directSale = false;
        _tokenMeta[_tokenId].bidSale = true;
        _tokenMeta[_tokenId].price = _price;
        _tokenMeta[_tokenId].status = true;
    }

    function executeBidOrder(uint256 _tokenId, uint256 _bidOrderID)
        public
        nonReentrant onlyOwnerOfToken(_tokenId) tokenExists(_tokenId)
    {
        safeTransferFrom(
            ownerOf(_tokenId),
            Bids[_tokenId][_bidOrderID].buyerAddress,
            _tokenId
        );
        payable(msg.sender).transfer(Bids[_tokenId][_bidOrderID].price);

        _tokenMeta[_tokenId].previousOwner = _tokenMeta[_tokenId].currentOwner;
        _tokenMeta[_tokenId].currentOwner = Bids[_tokenId][_bidOrderID].buyerAddress;
        _tokenMeta[_tokenId].numberOfTransfers += 1;
        _tokenMeta[_tokenId].price = Bids[_tokenId][_bidOrderID].price;
        _tokenMeta[_tokenId].bidSale = false;
        _tokenMeta[_tokenId].status = false;

       
        emit BidExecuted(Bids[_tokenId][_bidOrderID].price);

    }

  function withdrawBidMoney(uint _tokenId, uint _bidId) public {
        require(msg.sender != _tokenMeta[_tokenId].currentOwner, "Owner can't withdraw");
        // BidOrder[] memory bids = Bids[_tokenId];

        require(Bids[_tokenId][_bidId].buyerAddress == msg.sender, "Bidder can only withdraw");
        require(Bids[_tokenId][_bidId].withdrawn == false,"Withdrawn");
        if (payable(msg.sender).send(Bids[_tokenId][_bidId].price)){
            Bids[_tokenId][_bidId].withdrawn = true;
        }
        else {
            revert("No Money left!");
        }

        //  if(!payable(msg.sender).send(Bids[_tokenId][_bidId].price) ){
        //     revert("Cannot withdraw, try again later");
        // } 
        
        // for (uint256 i = 0; i < bids.length; i++) {
        //     if(bids[i].buyerAddress == msg.sender){
        //         if (!payable(bids[i].buyerAddress).send(bids[i].price)) {
        //             revert("Cannot withdraw, try again later");
        //         }   
        //     }
        // }
    }
}
