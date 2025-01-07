// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

contract ShoebumxToken is ERC20, Ownable {
    uint256 INITIAL_SUPPLY = 1_000_000 * (10 ** decimals());
    uint256 public constant TOKENS_PER_ETH = 100 * 10**18; // 50 tokens per ETH

    constructor() ERC20("ShoebumxToken", "SBX") Ownable(msg.sender) {
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount * (10 ** decimals()));
    }

    function buyTokens() external payable {
        require(msg.value >= 0.1 ether, "Minimum purchase is 0.1 ETH");
        
        // Calculate tokens to mint (10 tokens per 0.2 ETH)
        uint256 tokensToMint = (msg.value * TOKENS_PER_ETH);
        _mint(msg.sender, tokensToMint);
    }
    
    // Allow owner to withdraw accumulated ETH
    function withdrawETH() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No ETH to withdraw");

        (bool success, ) = owner().call{value: balance}("");
        require(success, "ETH withdrawal failed");
    }
}
