// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./Libraries/LibShare.sol";

contract PNDC_ERC1155 is ERC1155, Ownable, ERC1155Supply {
    
    event RoyaltiesSetForTokenId(
        uint256 tokenId,
        LibShare.Share[] royalties
    );

    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    mapping(uint256 => LibShare.Share[]) public royaltiesByTokenId;
    mapping(uint256 => string) public _uris;

    constructor(string memory uri) ERC1155(uri) {}

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function setTokenUri(string memory _uri, uint256 _tokenId) public {
        _uris[_tokenId] = _uri;
    }

    function mint(
        address account,
        uint256 amount,
        bytes memory data,
        string memory uri,
        LibShare.Share[] memory royalties
    ) public returns(uint256){
        uint256 tokenId = _tokenIdCounter.current();
        _setRoyaltiesByTokenId(tokenId, royalties);
        _tokenIdCounter.increment();
        _mint(account, tokenId, amount, data);
        setTokenUri(uri, tokenId);
        return tokenId;
    }

    function burn(address _from, uint256 _id, uint256 _amount) public {
        require(balanceOf(_from, _id) >= _amount,"7");

        _burn(_from, _id, _amount);
    }

    function _setRoyaltiesByTokenId(
        uint256 _tokenId,
        LibShare.Share[] memory royalties
    ) internal {
        require(royalties.length <= 10,"12");
        delete royaltiesByTokenId[_tokenId];
        uint256 sumRoyalties = 0;
        for (uint256 i = 0; i < royalties.length; i++) {
            require(
                royalties[i].account != address(0x0),
                "13"
            );
            require(royalties[i].value != 0, "14");
            royaltiesByTokenId[_tokenId].push(royalties[i]);
            sumRoyalties += royalties[i].value;
        }
        require(sumRoyalties < 10000, "15");

        emit RoyaltiesSetForTokenId(_tokenId, royalties);
    }

    function getRoyalties(uint256 _tokenId)
        external
        view
        returns (LibShare.Share[] memory)
    {
        return royaltiesByTokenId[_tokenId];
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155, ERC1155Supply) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}
