// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

interface IGemsNFT {
    function mint(address minter, uint256 id) external;
    function burn(address burner, uint256 id) external; 
}

contract GemsForgingLogic  {
    address private immutable GEMSNFT_CONTRACT_ADDRESS;
    uint256 public constant ZERO = 0;
    uint256 public constant ONE = 1;
    uint256 public constant TWO = 2;
    uint256 public constant THREE = 3;
    uint256 public constant FOUR = 4;
    uint256 public constant FIVE = 5;
    uint256 public constant SIX = 6;
    mapping (address => uint256) public lastMint;
    IERC1155 public gemsNFTContract;
    IGemsNFT public gemsNFT;


    constructor(address gemsNftContractAddress) {
        GEMSNFT_CONTRACT_ADDRESS = gemsNftContractAddress;
        gemsNFT = IGemsNFT(gemsNftContractAddress);
        gemsNFTContract = IERC1155(GEMSNFT_CONTRACT_ADDRESS);
    }

    function forge(uint256 id) external {
        if(id == ZERO || id == ONE || id == TWO ){
            uint256 elapsedTime = block.timestamp - lastMint[msg.sender];
            require(elapsedTime > 1 minutes, "ForgeNFTs: Not enough time has passed since the last mint.");
            lastMint[msg.sender] = block.timestamp;
            gemsNFT.mint(msg.sender, id);
        }
        else if(id == THREE){
            require(gemsNFTContract.balanceOf(msg.sender, ZERO) > 0, "ForgeNFTs: Not enough ZERO tokens.");
            require(gemsNFTContract.balanceOf(msg.sender, ONE) > 0, "ForgeNFTs: Not enough ONE tokens.");
            gemsNFT.burn(msg.sender,ZERO);
            gemsNFT.burn(msg.sender,ONE);
            gemsNFT.mint(msg.sender, THREE);
        }
        else if(id == FOUR){
            require(gemsNFTContract.balanceOf(msg.sender, TWO) > 0, "ForgeNFTs: Not enough TWO tokens.");
            require(gemsNFTContract.balanceOf(msg.sender, ONE) > 0, "ForgeNFTs: Not enough ONE tokens.");
            gemsNFT.burn(msg.sender,TWO);
            gemsNFT.burn(msg.sender,ONE);
            gemsNFT.mint(msg.sender, FOUR);
        }
        else if(id == FIVE){
            require(gemsNFTContract.balanceOf(msg.sender, TWO) > 0, "ForgeNFTs: Not enough TWO tokens.");
            require(gemsNFTContract.balanceOf(msg.sender, ZERO) > 0, "ForgeNFTs: Not enough ZERO tokens.");
            gemsNFT.burn(msg.sender,TWO);
            gemsNFT.burn(msg.sender,ZERO);
            gemsNFT.mint(msg.sender, FIVE);
        }
        else if(id == SIX){
            require(gemsNFTContract.balanceOf(msg.sender, TWO) > 0, "ForgeNFTs: Not enough TWO tokens.");
            require(gemsNFTContract.balanceOf(msg.sender, ZERO) > 0, "ForgeNFTs: Not enough ZERO tokens.");
            require(gemsNFTContract.balanceOf(msg.sender, ONE) > 0, "ForgeNFTs: Not enough ONE tokens.");
            gemsNFT.burn(msg.sender,TWO);
            gemsNFT.burn(msg.sender,ZERO);
            gemsNFT.burn(msg.sender,ONE);
            gemsNFT.mint(msg.sender, SIX);
        } 
    }

    function trade(uint256 tradeIn, uint256 for_) external {
        require(gemsNFTContract.balanceOf(msg.sender, tradeIn) > 0, "ForgeNFTs: No token to trade in.");
        require(for_ < 3, "ForgeNFTs: You can't trade for those tokens.");
        gemsNFT.burn(msg.sender,tradeIn);
        gemsNFT.mint(msg.sender, for_);
    }

    function smelt(uint256 id) external {
        require(id > 2, "ForgeNFTs: You can't burn this token.");
        require(gemsNFTContract.balanceOf(msg.sender, id) > 0, "ForgeNFTs: No tokens to burn.");
        gemsNFT.burn(msg.sender,id);
    }
}