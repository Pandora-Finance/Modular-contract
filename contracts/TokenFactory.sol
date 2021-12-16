// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./Auction/Bid.sol";
import "./Libraries/LibERC721.sol";
import "./Libraries/LibCollection.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract TokenFactory is NFTBid, UUPSUpgradeable {

    using Counters for Counters.Counter;
    Counters.Counter public collectionIdTracker;

    event ERC721Deployed(address indexed _from, address _tokenAddress);

    function initialize(address _address) initializer public {
        PNDCAddress = _address;
        initialize();
        __UUPSUpgradeable_init();
    }

    function deployERC721(string memory name, string memory symbol, string memory description, LibShare.Share[] memory royalties) external {

        collectionIdTracker.increment();

        address collectionAddress = LibERC721.deployERC721(name, symbol, royalties);

        LibCollection.CollectionMeta memory meta = LibCollection.CollectionMeta(
            collectionIdTracker.current(),
            name,
            symbol,
            collectionAddress,
            msg.sender,
            description
        );

        collections[collectionIdTracker.current()] = meta;
        

        ownerToCollections[msg.sender].push(collectionIdTracker.current());
        collectionToOwner[collectionAddress] = msg.sender;

        emit ERC721Deployed(msg.sender, collectionAddress);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}

}
