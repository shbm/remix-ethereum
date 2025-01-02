// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract PartialRefund is ERC20 {
    // Define maximum token supply: 1,000,000 tokens (with 18 decimals)
    uint256 public constant MAX_SUPPLY = 1_000_000 * 10**18;

    // Each purchase (1 Ether) gives 1000 tokens
    uint256 public constant TOKENS_PER_ETHER = 1000 * 10**18;

    address private _owner;


    constructor() ERC20("TKN", "TKN") {
        _owner = msg.sender;
        _mint(msg.sender, 10_000 * 10**18);
    }

    /**
     * @dev Override the decimals to 18 as requested.
     */
    function decimals() public pure override returns (uint8) {
        return 18;
    }

    /**
     * @dev Buy 1000 tokens for 1 Ether.
     *
     * Requirements:
     * - `msg.value` must be exactly 1 Ether.
     * - totalSupply() + 1000 tokens must not exceed 1,000,000 tokens.
     *
     * This function mints new tokens directly to the sender.
     */
    function buyTokens() external payable {
        // Ensure exactly 1 Ether is sent
        require(msg.value == 1 ether, "Must send exactly 1 Ether to buy tokens");

        // Check if minting exceeds max supply
        require(
            totalSupply() + TOKENS_PER_ETHER <= MAX_SUPPLY,
            "Minting would exceed maximum token supply"
        );

        // Mint tokens to msg.sender
        _mint(msg.sender, TOKENS_PER_ETHER);
    }

    /**
     * @dev Allows the owner to withdraw all accumulated Ether from the contract.
     */
    function withdraw() public {
        require(msg.sender == _owner, "only owner");

        // Transfer all Ether to contract owner
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Failed to withdraw Ether");
    }
}
