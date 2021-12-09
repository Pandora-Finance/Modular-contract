// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "./Libraries/LibShare.sol";
import "./Libraries/LibERC721.sol";
import "./NFTStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract TokenFactory is OwnableUpgradeable, UUPSUpgradeable, NFTV1Storage {

    using Counters for Counters.Counter;
    Counters.Counter public collectionIdTracker;

    event ERC721Deployed(address indexed _from, address _tokenAddress);

    function initialize() initializer public {
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    function deployERC721(string memory name, string memory symbol, LibShare.Share[] memory royalties) external {

        collectionIdTracker.increment();

        address collectionAddress = LibERC721.deployERC721(name, symbol, royalties);
        collections[collectionIdTracker.current()] = collectionAddress;
        
        emit ERC721Deployed(msg.sender, collectionAddress);
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}
}
