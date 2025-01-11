// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

interface ICrystalForge {
    function burn(address account, uint256 id, uint256 value) external;
    function mintByMinter(address account, uint256 id, uint256 amount) external;
    function balanceOf(address account, uint256 id) external view returns (uint256);
    
    // Crystal constants
    function RUBY() external view returns (uint256);
    function SAPPHIRE() external view returns (uint256);
    function EMERALD() external view returns (uint256);
    function SOLAR_GEM() external view returns (uint256);
    function OCEAN_GEM() external view returns (uint256);
    function NATURE_GEM() external view returns (uint256);
    function PRISMATIC_GEM() external view returns (uint256);
}

contract CrystalForgeLogic is ERC1155Holder {
    ICrystalForge public crystalForge;
    
    constructor(address _crystalForge) {
        crystalForge = ICrystalForge(_crystalForge);
    }

    function forge(uint256 targetGem) public {
        if (targetGem == crystalForge.SOLAR_GEM()) {
            require(
                crystalForge.balanceOf(msg.sender, crystalForge.RUBY()) >= 1 &&
                crystalForge.balanceOf(msg.sender, crystalForge.SAPPHIRE()) >= 1,
                "Requires 1 Ruby and 1 Sapphire to forge Solar Gem"
            );
            crystalForge.burn(msg.sender, crystalForge.RUBY(), 1);
            crystalForge.burn(msg.sender, crystalForge.SAPPHIRE(), 1);
        } else if (targetGem == crystalForge.OCEAN_GEM()) {
            require(
                crystalForge.balanceOf(msg.sender, crystalForge.SAPPHIRE()) >= 1 &&
                crystalForge.balanceOf(msg.sender, crystalForge.EMERALD()) >= 1,
                "Requires 1 Sapphire and 1 Emerald to forge Ocean Gem"
            );
            crystalForge.burn(msg.sender, crystalForge.SAPPHIRE(), 1);
            crystalForge.burn(msg.sender, crystalForge.EMERALD(), 1);
        } else if (targetGem == crystalForge.NATURE_GEM()) {
            require(
                crystalForge.balanceOf(msg.sender, crystalForge.RUBY()) >= 1 &&
                crystalForge.balanceOf(msg.sender, crystalForge.EMERALD()) >= 1,
                "Requires 1 Ruby and 1 Emerald to forge Nature Gem"
            );
            crystalForge.burn(msg.sender, crystalForge.RUBY(), 1);
            crystalForge.burn(msg.sender, crystalForge.EMERALD(), 1);
        } else if (targetGem == crystalForge.PRISMATIC_GEM()) {
            require(
                crystalForge.balanceOf(msg.sender, crystalForge.RUBY()) >= 1 &&
                crystalForge.balanceOf(msg.sender, crystalForge.SAPPHIRE()) >= 1 &&
                crystalForge.balanceOf(msg.sender, crystalForge.EMERALD()) >= 1,
                "Requires all three basic gems to forge Prismatic Gem"
            );
            crystalForge.burn(msg.sender, crystalForge.RUBY(), 1);
            crystalForge.burn(msg.sender, crystalForge.SAPPHIRE(), 1);
            crystalForge.burn(msg.sender, crystalForge.EMERALD(), 1);
        } else {
            revert("Invalid gem fusion target");
        }
        
        crystalForge.mintByMinter(msg.sender, targetGem, 1);
    }

    function burnCrystal(uint256 gemId, uint256 amount) public {
        require(
            gemId >= crystalForge.SOLAR_GEM() && 
            gemId <= crystalForge.PRISMATIC_GEM(), 
            "Only fused gems can be shattered"
        );
        require(
            crystalForge.balanceOf(msg.sender, gemId) >= amount,
            "Insufficient gems to shatter"
        );
        crystalForge.burn(msg.sender, gemId, amount);
    }

    function trade(uint256 fromGem, uint256 toGem) public {
        require(fromGem <= crystalForge.PRISMATIC_GEM(), "Invalid gem type");
        require(
            toGem <= crystalForge.EMERALD(), 
            "Can only trade for basic gems"
        );
        require(
            crystalForge.balanceOf(msg.sender, fromGem) >= 1,
            "No gem to trade"
        );
        
        crystalForge.burn(msg.sender, fromGem, 1);
        crystalForge.mintByMinter(msg.sender, toGem, 1);
    }
}