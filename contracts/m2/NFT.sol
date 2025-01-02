// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract ShubhamNFT is ERC721 {
    uint256 private _nextTokenId;
    uint256 public tokenSupply = 0;
    uint256 public constant maxTokens = 10;
    uint256 public constant price = 0 ether;
    address immutable _owner;

    modifier isOwner() {
        require(msg.sender == _owner , "not contract owner");
        _;
    }

    constructor() ERC721("ShubhamNFT", "SNFT") {
        _owner = msg.sender;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://bafybeihmthev5uhesxbc7f6thrmckdystzqvpvzmr4hkmf4kjephwxmto4/";
    }

    function viewBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function mint(address to) external {
        require(tokenSupply < maxTokens, "can't mint more than 10 tokens");
        _mint(to, tokenSupply);
        tokenSupply++;
    }

    function withdraw() external isOwner {
        payable(_owner).transfer(address(this).balance);
    }
}