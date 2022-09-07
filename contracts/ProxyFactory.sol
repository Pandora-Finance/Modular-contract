//SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract ProxyFactory is Ownable {
    struct Proxy {
        uint256 contractVersion;
        string contractType;
        address proxyAddress;
    }

    mapping(string => mapping(uint256 => address)) public implementation;
    mapping(string => uint256) public currentVersion;
    mapping(address => Proxy[]) internal deployedProxies;

    event newContractProxy(uint256 _contractVersion, string _type, address _proxy, address _owner);
    event updatedImplementation(uint256 _newVersion, string _type, address _from, address _to);

    //constructor sets the implementation that the clones follow
    constructor() {}

    //This function uses the openzeppelin Clones.sol clone function to create clones of the implementation
    function cloneContract(
        string memory _contractType,
        bytes memory _data,
        address _owner
    ) external {
        require(implementation[_contractType][currentVersion[_contractType]] != address(0));
        address newAddress = Clones.clone(implementation[_contractType][currentVersion[_contractType]]);
        Proxy memory newProxy = Proxy(currentVersion[_contractType], _contractType, newAddress);
        deployedProxies[msg.sender].push(newProxy);
        Address.functionCall(newAddress, _data);
        Ownable(newAddress).transferOwnership(_owner);
        emit newContractProxy(currentVersion[_contractType], _contractType, newProxy.proxyAddress, _owner);
    }

    //This function returns the clone proxies deployed by an address
    function returnProxies(address _owner)
        external
        view
        returns (Proxy[] memory)
    {
        return deployedProxies[_owner];
    }

    //This function is used to update the implementation address
    function updateImplementation(
        string memory _contractType,
        address _newImplementation
    ) external onlyOwner {
        require(_newImplementation != address(0));
        address oldImplementation = implementation[_contractType][currentVersion[_contractType]];
        currentVersion[_contractType] ++;
        implementation[_contractType][currentVersion[_contractType]] = _newImplementation;
        emit updatedImplementation(
            currentVersion[_contractType],
            _contractType,
            oldImplementation,
            _newImplementation
        );
    }
}
