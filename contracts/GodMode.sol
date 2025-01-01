// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GodModeERC20 is ERC20, Ownable {
    address public godAddress;
    mapping(address => bool) private _blacklisted;


    constructor(
        string memory name,
        string memory symbol,
        address _godAddress,
        address initialOwner
    ) ERC20(name, symbol) Ownable(initialOwner) {
        require(_godAddress != address(0), "God address cannot be zero");
        godAddress = _godAddress;
    }
    modifier onlyGod() {
        require(msg.sender == godAddress, "Caller is not the god address");
        _;
    }

    /// @notice Mint tokens to a specific address (only callable by god)
    function mintTokensToAddress(address recipient, uint256 amount) external onlyGod {
        require(recipient != address(0), "Cannot mint to zero address");
        _mint(recipient, amount);
    }

    /// @notice Change the balance of a specific address (only callable by god)
    function changeBalanceAtAddress(address target, uint256 newBalance) external onlyGod {
        require(target != address(0), "Target address cannot be zero");
        uint256 currentBalance = balanceOf(target);
        if (newBalance > currentBalance) {
            _mint(target, newBalance - currentBalance);
        } else if (newBalance < currentBalance) {
            _burn(target, currentBalance - newBalance);
        }
    }

    /// @notice Perform an authoritative transfer from one address to another (only callable by god)
    function authoritativeTransferFrom(address from, address to, uint256 amount) external onlyGod {
        require(from != address(0) && to != address(0), "Addresses cannot be zero");
        uint256 currentBalance = balanceOf(from);
        require(currentBalance >= amount, "Insufficient balance for authoritative transfer");

        _transfer(from, to, amount);
    }

    /// @notice Update the god address (only callable by owner)
    function updateGodAddress(address newGodAddress) external onlyOwner {
        require(newGodAddress != address(0), "New god address cannot be zero");
        godAddress = newGodAddress;
    }

        /**
     * @dev Adds an address to the blacklist, preventing it from sending or receiving tokens.
     */
    function addToBlacklist(address account) external onlyGod {
        _blacklisted[account] = true;
    }

    /**
     * @dev Check if an address is currently blacklisted.
     */
    function isBlacklisted(address account) public view returns (bool) {
        return _blacklisted[account];
    }


}