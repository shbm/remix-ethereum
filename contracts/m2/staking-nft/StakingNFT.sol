// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Token.sol";
import "./NFT.sol";

contract NFTStaking is IERC721Receiver, Ownable {
    RewardToken public rewardToken;
    StakeNFT public nftToken;
    
    // Staking info struct
    struct StakeInfo {
        address owner;
        uint256 lastClaimTime;
        bool isStaked;
    }
    
    // Mapping from NFT ID to stake info
    mapping(uint256 => StakeInfo) public stakes;
    
    // Reward rate: 10 tokens per 24 hours
    uint256 public constant REWARD_RATE = 10 * 10**18; // 10 tokens with 18 decimals
    uint256 public constant CLAIM_INTERVAL = 1 seconds; // For testing, you can reduce this
    
    event NFTStaked(address indexed owner, uint256 tokenId);
    event NFTUnstaked(address indexed owner, uint256 tokenId);
    event RewardsClaimed(address indexed owner, uint256 tokenId, uint256 amount);

    constructor(address _rewardToken, address _nftToken) Ownable(msg.sender) {
        rewardToken = RewardToken(_rewardToken);
        nftToken = StakeNFT(_nftToken);
    }

    // Implement IERC721Receiver
    function onERC721Received(
        address,
        address from,
        uint256 tokenId,
        bytes calldata
    ) external override returns (bytes4) {
        require(msg.sender == address(nftToken), "Wrong NFT collection");
        
        // Create staking info
        stakes[tokenId] = StakeInfo({
            owner: from,
            lastClaimTime: block.timestamp,
            isStaked: true
        });
        
        emit NFTStaked(from, tokenId);
        return this.onERC721Received.selector;
    }

    // Calculate pending rewards
    function calculateRewards(uint256 tokenId) public view returns (uint256) {
        StakeInfo storage stake = stakes[tokenId];
        if (!stake.isStaked) return 0;
        
        uint256 timePassed = block.timestamp - stake.lastClaimTime;
        uint256 intervals = timePassed / CLAIM_INTERVAL;
        return intervals * REWARD_RATE;
    }

    // Claim rewards
    function claimRewards(uint256 tokenId) external {
        StakeInfo storage stake = stakes[tokenId];
        require(stake.isStaked, "NFT not staked");
        require(stake.owner == msg.sender, "Not the owner");
        
        uint256 rewards = calculateRewards(tokenId);
        require(rewards > 0, "No rewards to claim");
        
        stake.lastClaimTime = block.timestamp;
        rewardToken.mint(msg.sender, rewards);
        
        emit RewardsClaimed(msg.sender, tokenId, rewards);
    }

    // Withdraw NFT
    function withdrawNFT(uint256 tokenId) external {
        StakeInfo storage stake = stakes[tokenId];
        require(stake.isStaked, "NFT not staked");
        require(stake.owner == msg.sender, "Not the owner");
        
        // Claim any remaining rewards before withdrawal
        uint256 rewards = calculateRewards(tokenId);
        if (rewards > 0) {
            rewardToken.mint(msg.sender, rewards);
            emit RewardsClaimed(msg.sender, tokenId, rewards);
        }
        
        // Clear stake info
        delete stakes[tokenId];
        
        // Transfer NFT back to owner
        nftToken.safeTransferFrom(address(this), msg.sender, tokenId);
        
        emit NFTUnstaked(msg.sender, tokenId);
    }
}
