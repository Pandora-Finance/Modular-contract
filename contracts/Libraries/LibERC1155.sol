// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "../TokenERC1155.sol";
import "./LibShare.sol";

library LibERC721 {
    function deployERC721(string memory uri, LibShare.Share[] memory royalties)
        external
        returns (address)
    {
        TokenERC1155 token = new TokenERC1155(uri);
        token.setRoyaltiesForCollection(royalties);
        token.transferOwnership(msg.sender);
        return address(token);
    }
}