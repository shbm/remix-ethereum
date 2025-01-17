// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

contract TokenSale is ERC20, Ownable2Step {
    uint256 public constant PRICE = 1 ether;
    uint256 public constant TOKENS_PER_ETH = 1000 * 10**18; // 1000 tokens with 18 decimals
    uint256 public constant MAX_SUPPLY = 1_000_000 * 10**18; // 1 million tokens with 18 decimals
    uint256 public constant BUYBACK_RATE = 500_000_000_000_000_000; // 0.5 ETH per 1000 tokens
    
    constructor() ERC20("MyToken", "MTK") Ownable(msg.sender) {}
    
    /**
     * @dev Override _update to add supply cap check
     * @param from The address tokens are transferred from
     * @param to The address tokens are transferred to
     * @param amount The amount of tokens being transferred
     */
    function _update(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        // If minting (from is address(0)), check against max supply
        if (from == address(0)) {
            require(
                totalSupply() + amount <= MAX_SUPPLY,
                "Would exceed max supply"
            );
        }
        
        super._update(from, to, amount);
    }
    
    /**
     * @notice Allows users to purchase tokens by sending ETH
     * @dev First uses existing tokens in contract, only mints if necessary
     */
    function mintTokens() public payable returns (bool) {
        require(msg.value == PRICE, "Must send exactly 1 ETH");
        uint256 contractBalance = balanceOf(address(this));

        if (contractBalance >= TOKENS_PER_ETH) {
            _transfer(address(this), msg.sender, TOKENS_PER_ETH);
        } else {
            if (contractBalance > 0) {
                uint256 remainingTokens = TOKENS_PER_ETH - contractBalance;
                _transfer(address(this), msg.sender, contractBalance);
                _mint(msg.sender, remainingTokens);
            } else {
                _mint(msg.sender, TOKENS_PER_ETH);
            }
        }
        return true;
    }



    /**
     * @notice Allows users to sell tokens back to the contract
     * @param amount The amount of tokens to sell back
     * @dev Uses checks-effects-interactions pattern for security
     */
    function sellBack(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        
        // Calculate ETH to return: (amount * 0.5 ETH) / 1000 tokens
        uint256 ethToReturn = (amount * BUYBACK_RATE) / TOKENS_PER_ETH;
        require(ethToReturn > 0, "Amount too small to generate ETH return");
        require(address(this).balance >= ethToReturn, "Insufficient ETH in contract");
        
        // First get the tokens - this will fail if user hasn't approved enough tokens
        require(transferFrom(msg.sender, address(this), amount), "Token transfer failed");
        
        // Then send ETH to user
        (bool success, ) = msg.sender.call{value: ethToReturn}("");
        require(success, "ETH transfer failed");
    }
    
    /**
     * @notice Allows the owner to withdraw accumulated ETH from the contract
     */
    function withdrawETH() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No ETH to withdraw");
        
        (bool success, ) = owner().call{value: balance}("");
        require(success, "ETH transfer failed");
    }
}