// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

contract GodModeToken is ERC20, Ownable2Step {
    address public godAddress;


    constructor(
        address _godAddress
    ) ERC20("GodModeToken","GMT") Ownable(msg.sender) {
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
}