// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./ShoebumxNFT.sol";

contract MintingController is Ownable {
    IERC20 public paymentToken;
    ShoebumxNFT public nftContract;
    uint256 public constant MINT_PRICE = 10 * 10**18; // 10 tokens
    
    constructor(
        address _paymentToken,
        address _nftContract
    ) Ownable(msg.sender) {
        paymentToken = IERC20(_paymentToken);
        nftContract = ShoebumxNFT(_nftContract);
    }
    
    function mintNFT() external returns (uint256) {
        require(
            paymentToken.transferFrom(msg.sender, address(this), MINT_PRICE),
            "Token transfer failed"
        );
        
        return nftContract.safeMint(msg.sender);
    }
    
    function withdrawTokens() external onlyOwner {
        uint256 balance = paymentToken.balanceOf(address(this));
        require(balance > 0, "No tokens to withdraw");
        
        bool success = paymentToken.transfer(owner(), balance);
        require(success, "Withdrawal failed");
    }
}