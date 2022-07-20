//SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface ITokenFactory {
    function initialize(address _address, address _feeAddress) external;

    function transferOwnership(address newOwner) external;
}

contract ProxyMarketplaceFactory is Ownable, ReentrancyGuard {
    address public implementation;
    mapping(address => address[]) internal deployedProxies;

    event newMarketplaceProxy(address _proxy, address _owner);
    event updatedImplementation(address _from, address _to);

    //constructor sets the implementation that the clones follow
    constructor(address _implementation) {
        require(_implementation != address(0));
        implementation = _implementation;
    }

    //This function uses the openzeppelin Clones.sol clone function to create clones of the implementation
    function _clone(
        address _pndc,
        address _feeAdress,
        address _owner
    ) external nonReentrant {
        address newProxy = Clones.clone(implementation);
        deployedProxies[msg.sender].push(newProxy);
        ITokenFactory(newProxy).initialize(_pndc, _feeAdress);
        ITokenFactory(newProxy).transferOwnership(_owner);
        emit newMarketplaceProxy(newProxy, _owner);
    }

    //This function returns the clone proxies deployed by an address
    function returnProxies(address _owner)
        public
        view
        returns (address[] memory)
    {
        return deployedProxies[_owner];
    }

    //This function is used to update the implementation address
    function updateImplementation(address _newImplementation)
        external
        onlyOwner
    {
        address oldImplementation = implementation;
        implementation = _newImplementation;
        emit updatedImplementation(oldImplementation, implementation);
    }
}
