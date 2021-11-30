// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../NFTMarketplace.sol";

contract NFTBid is
    NFTMarketplace
{

    event BidOrderReturn(BidOrder bid);
    event BidExecuted(uint256 price);

    // function getAll_NFTBids(uint256 _tokenId)
    //     public
    //     view
    //     virtual
    //     returns (BidOrder[] memory)
    // {
    //     require(_exists(_tokenId));
    //     return Bids[_tokenId];
    // }

    
    function Bid(uint256 _tokenId) public payable tokenExists(_tokenId){        
        require(ownerOf(_tokenId) != _msgSender(), "Owners Can't Bid");
        require(
            _tokenMeta[_tokenId].status == true,
            "NFT is not open for sale right now"
        );
        require(
            _tokenMeta[_tokenId].price <= msg.value,
            "Bid price must be greater than or equal to the selling price"
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
       // TokenMeta memory token = _tokenMeta[_tokenId];
        
        safeTransferFrom(
            ownerOf(_tokenId),
            Bids[_tokenId][_bidOrderID].buyerAddress,
            _tokenId
        );
        // address sendTo = token.currentOwner;
        // payable(sendTo).transfer(msg.value);
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
        require(msg.sender != _tokenMeta[_tokenId].currentOwner, "Only Bidder other than the owner are allowed to withdraw money");
        // BidOrder[] memory bids = Bids[_tokenId];

        require(Bids[_tokenId][_bidId].buyerAddress == msg.sender, "Only the Bidder of that specific Bid can withdraw back his funds");
        require(Bids[_tokenId][_bidId].withdrawn == false," You have already Withdrawn");
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
