// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MyERC721 is Ownable, ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    uint256 private _totalSupply;

    constructor() ERC721("myERC721", "MyERC721") {}

    function safeMint(address to) external onlyOwner returns (uint256) {
        uint256 tokenId = getIncrementTokenId();

        _safeMint(to, tokenId);
        _totalSupply++;

        return tokenId;
    }

    function mint(address to) external onlyOwner {
        uint256 tokenId = getIncrementTokenId();

        _mint(to, tokenId);
        _totalSupply++;
    }

    function getIncrementTokenId() internal returns (uint256) {
        _tokenIds.increment();
        return _tokenIds.current();
    }

    function burn(uint256 tokenId) external {
        _burn(tokenId);
        _totalSupply--;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "https://ipfs.io/ipfs/";
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }
}
