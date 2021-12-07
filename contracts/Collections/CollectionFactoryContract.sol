// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
 
 import "../NFTStorage.sol";
 import "../Libraries/LibCollectionMeta.sol";
 import "../Libraries/LibMeta.sol";
 import "../NFTFactoryContract.sol";
 import "@openzeppelin/contracts/utils/Counters.sol";

contract CollectionFactoryContract is NFTFactoryContract {

    using Counters for Counters.Counter;
    uint private collectionsTracker;

    event collectionCreated(uint256 collectionId, string name);

    function createCollection(string memory _name) 
    public 
    returns(uint256) 
    {
         // as CollectionsMeta struct contains an array, it can't be initialised the standard way,
        // so we create an empty element in collections array, and fill all variables at that index

        collectionsTracker = collections.length;

        collections.push();

        LibCollectionMeta.CollectionMeta storage meta = collections[collectionsTracker];

        meta.collectionId = collectionsTracker;
        meta.name = _name;
        meta.totalTokens = 0;

        collections[collectionsTracker] = meta;

        emit collectionCreated(collectionsTracker, _name);

        return collectionsTracker;

    }

    function fetchCollectionTokens(uint256 _collectionId) public view returns(LibMeta.TokenMeta[] memory) {
        LibCollectionMeta.CollectionMeta memory meta = collections[_collectionId];
        return meta.tokens;
    }

}