// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract RewardToken is ERC20, Ownable {
    address minter;
    constructor() ERC20("Reward Token", "RWD") Ownable(msg.sender) {}

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function mintStakeRewards(address to, uint256 amount) public  {
        require(msg.sender == minter, "Not the minter");
        _mint(to, amount);
    }

    function setMinter(address theMinter) external onlyOwner {
        minter = theMinter;
    }

}
