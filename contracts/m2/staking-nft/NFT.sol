// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract StakeNFT is ERC721 {
    uint256 public _tokenIdCounter;

    constructor() ERC721("Stake NFT", "SNFT") {}

    function safeMint(address to) public {
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;
        _safeMint(to, tokenId);
    }
}

