// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable2Step.sol";

contract ShoebumxNFT is ERC721, Ownable {
    uint256 public currentTokenId;
    uint256 public constant TOTAL_SUPPLY = 10;
    address public minterContract;

    constructor() ERC721("ShoebumxNFT", "SBXNFT") Ownable(msg.sender) {}

    // Set the authorized minter contract
    function setMinterContract(address _minterContract) external onlyOwner {
        minterContract = _minterContract;
    }
    function safeMint(address to) public returns (uint256) {
        require(minterContract == msg.sender, "ShoebumxNFT: Not authorized to mint NFT");
        require(currentTokenId <= TOTAL_SUPPLY, "SBXNFT: Maximum supply reached");
        uint256 tokenId = currentTokenId++;
        _safeMint(to, tokenId);
        return tokenId;
    }
}