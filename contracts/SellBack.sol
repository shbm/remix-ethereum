// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// OpenZeppelin imports
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title MyTokenSale
 * @dev A simple ERC20 token sale contract that:
 *  1) Lets users buy 1000 tokens for 1 Ether (until total supply hits 1M).
 *  2) Lets users sell their tokens back at a rate of 0.5 Ether per 1000 tokens.
 *  3) Restricts total minted supply to 1,000,000 tokens (18 decimals).
 *  4) Allows the owner to withdraw all Ether from the contract.
 */
contract MyTokenSale is ERC20 {
    // Max token supply: 1,000,000 tokens with 18 decimals
    uint256 public constant MAX_SUPPLY = 1_000_000 * 10**18;

    // Buying price: 1 Ether => 1000 tokens
    uint256 public constant TOKENS_PER_ETHER = 1000 * 10**18;

    // Selling rate: 1000 tokens => 0.5 Ether
    // For partial amounts, e.g. 500 tokens => 0.25 Ether, etc.
    // Using a ratio approach: (amount * 0.5 ether) / 1000
    uint256 public constant SELL_RATE_NUMERATOR = 0.5 ether;
    uint256 public constant SELL_RATE_DENOMINATOR = 1000;
    address private _owner;

    constructor() ERC20("TKN", "TKN") {
        // Optionally mint some tokens to the owner here,
        // but do not exceed MAX_SUPPLY.
        _mint(msg.sender, 10_000 * 10**18);
    }

    /**
     * @dev Overriding decimals to 18, as required.
     */
    function decimals() public pure override returns (uint8) {
        return 18;
    }

    /**
     * @dev Buys 1000 tokens for exactly 1 Ether.
     *
     * Requirements:
     * - `msg.value == 1 ether`
     * - `totalSupply() + 1000 tokens <= MAX_SUPPLY`
     */
    function buyTokens() external payable {
        require(msg.value == 1 ether, "Must send exactly 1 Ether to buy 1000 tokens");

        // Ensure we don’t exceed max supply
        require(
            totalSupply() + TOKENS_PER_ETHER <= MAX_SUPPLY,
            "Purchase would exceed max token supply"
        );

        // Mint 1000 tokens to buyer
        _mint(msg.sender, TOKENS_PER_ETHER);
    }

    /**
     * @dev Sells `amount` tokens back to the contract at a rate of
     *      0.5 Ether per 1000 tokens.  
     *
     * IMPORTANT: Users must first approve this contract to spend at least
     *            `amount` of their tokens, e.g.:
     *                 myToken.approve(address(this), amount)
     * 
     * For partial amounts, the Ether is paid proportionally. Example:
     *  - If `amount == 1000`, user gets 0.5 Ether.
     *  - If `amount == 500`, user gets 0.25 Ether, etc.
     *
     * Requirements:
     * - Contract must have enough Ether to pay the user.
     * - `amount > 0`
     */
    function sellBack(uint256 amount) external {
        require(amount > 0, "Cannot sell back zero tokens");

        // Calculate how much Ether the user should receive
        // (amount * 0.5 ETH) / 1000
        uint256 etherOwed = (amount * SELL_RATE_NUMERATOR) / SELL_RATE_DENOMINATOR;

        // Ensure contract has enough Ether to pay
        require(address(this).balance >= etherOwed, "Not enough Ether in contract");

        // Pull tokens from user’s account into this contract
        // NOTE: User must have called `approve(address(this), amount)` first.
        bool success = transferFrom(msg.sender, address(this), amount);
        require(success, "transferFrom failed; check allowance");

        // Pay the user
        (success, ) = payable(msg.sender).call{value: etherOwed}("");
        require(success, "Ether transfer to user failed");
    }

    /**
     * @dev Allows the owner to withdraw all Ether held in the contract.
     */
    function withdraw() public  {
        // Transfer total contract balance to owner
        require(msg.sender == _owner, "only owner");
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Failed to withdraw Ether");
    }
}
