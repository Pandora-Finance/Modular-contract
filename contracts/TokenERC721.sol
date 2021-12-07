// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./Libraries/LibShare.sol";

contract TokenERC721 is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    event RoyaltiesSetForCollection(LibShare.Share[] royalties);
    event RoyaltiesSetForTokenId(uint256 tokenId, LibShare.Share[] royalties);

    Counters.Counter private _tokenIdCounter;

    LibShare.Share[] public collectionRoyalties;
    mapping(uint256 => LibShare.Share[]) public royaltiesByTokenId;

    constructor(
        string memory name,
        string memory symbol,
        LibShare.Share[] memory royalties
    ) ERC721(name, symbol) {
        setRoyaltiesForCollection(royalties);
    }

    function safeMint(
        address to,
        string memory uri,
        LibShare.Share[] memory royalties
    ) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        setRoyaltiesByTokenId(tokenId, royalties);
    }

    function setRoyaltiesByTokenId(
        uint256 _tokenId,
        LibShare.Share[] memory royalties
    ) public onlyOwner {
        delete royaltiesByTokenId[_tokenId];
        _setRoyaltiesArray(royaltiesByTokenId[_tokenId], royalties);
        emit RoyaltiesSetForTokenId(_tokenId, royalties);
    }

    function setRoyaltiesForCollection(LibShare.Share[] memory royalties)
        public
        onlyOwner
    {
        delete collectionRoyalties;
        _setRoyaltiesArray(collectionRoyalties, royalties);
        emit RoyaltiesSetForCollection(royalties);
    }

    function getRoyalties(uint256 _tokenId)
        external
        view
        returns (LibShare.Share[] memory)
    {
        if (royaltiesByTokenId[_tokenId].length != 0) {
            return royaltiesByTokenId[_tokenId];
        }
        return collectionRoyalties;
    }

    function _setRoyaltiesArray(
        LibShare.Share[] storage royaltiesArr,
        LibShare.Share[] memory royalties
    ) internal {
        uint256 sumRoyalties = 0;
        for (uint256 i = 0; i < royalties.length; i++) {
            require(
                royalties[i].account != address(0x0),
                "Royalty recipient should be present"
            );
            require(royalties[i].value != 0, "Royalty value should be > 0");
            royaltiesArr.push(royalties[i]);
            sumRoyalties += royalties[i].value;
        }
        require(sumRoyalties < 10000, "Sum of Royalties > 100%");
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
