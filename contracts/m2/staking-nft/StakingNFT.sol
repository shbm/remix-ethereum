// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";
import "./Token.sol";
import "./NFT.sol";

/**
 * @title NFT Staking Contract
 * @dev Implements staking functionality for NFTs with ERC20 token rewards
 *
 * This contract allows users to stake their NFTs and earn ERC20 tokens as rewards.
 * Users can claim rewards every second (configurable) and withdraw their NFTs at any time.
 * The contract ensures only the original staker can claim rewards and withdraw the NFT.
 */
contract NFTStaking is IERC721Receiver, Ownable {
    /// @notice The ERC20 token used for rewards
    RewardToken public rewardToken;
    
    /// @notice The NFT contract that can be staked
    StakeNFT public nftToken;
    
    /**
     * @dev Struct to store staking information for each NFT
     * @param owner Address of the NFT owner who staked
     * @param lastClaimTime Timestamp of the last reward claim
     * @param isStaked Boolean indicating if the NFT is currently staked
     */
    struct StakeInfo {
        address owner;
        uint256 lastClaimTime;
        bool isStaked;
    }
    
    /// @notice Maps NFT token IDs to their staking information
    mapping(uint256 => StakeInfo) public stakes;
    
    /// @notice Reward amount per claim interval (10 tokens with 18 decimals)
    uint256 public constant REWARD_RATE = 10 * 10**18;
    
    /// @notice Time required between reward claims (1 second for testing)
    uint256 public constant CLAIM_INTERVAL = 1 seconds;
    
    /// @notice Emitted when an NFT is staked
    event NFTStaked(address indexed owner, uint256 tokenId);
    
    /// @notice Emitted when an NFT is withdrawn from staking
    event NFTUnstaked(address indexed owner, uint256 tokenId);
    
    /// @notice Emitted when rewards are claimed
    event RewardsClaimed(address indexed owner, uint256 tokenId, uint256 amount);

    /**
     * @dev Constructor initializes the staking contract with token addresses
     * @param _rewardToken Address of the ERC20 reward token contract
     * @param _nftToken Address of the NFT contract that can be staked
     */
    constructor(address _rewardToken, address _nftToken) Ownable(msg.sender) {
        rewardToken = RewardToken(_rewardToken);
        nftToken = StakeNFT(_nftToken);
    }

    /**
     * @dev Handles the receipt of an NFT
     * @notice Automatically called when an NFT is transferred to this contract
     * @param from Address of the NFT sender
     * @param tokenId ID of the transferred NFT
     * @return bytes4 The function selector to confirm receipt
     */
    function onERC721Received(
        address,
        address from,
        uint256 tokenId,
        bytes calldata
    ) external override returns (bytes4) {
        // Verify NFT is from the correct collection
        require(msg.sender == address(nftToken), "Wrong NFT collection");
        
        // Create new staking record
        stakes[tokenId] = StakeInfo({
            owner: from,
            lastClaimTime: block.timestamp,
            isStaked: true
        });
        
        emit NFTStaked(from, tokenId);
        return this.onERC721Received.selector;
    }

    /**
     * @dev Calculates pending rewards for a staked NFT
     * @param tokenId ID of the NFT to calculate rewards for
     * @return uint256 Amount of reward tokens earned
     */
    function calculateRewards(uint256 tokenId) public view returns (uint256) {
        StakeInfo storage stake = stakes[tokenId];
        if (!stake.isStaked) return 0;
        
        uint256 timePassed = block.timestamp - stake.lastClaimTime;
        uint256 intervals = timePassed / CLAIM_INTERVAL;
        return intervals * REWARD_RATE;
    }

    /**
     * @dev Claims accumulated rewards for a staked NFT
     * @param tokenId ID of the NFT to claim rewards for
     * @notice Only the original staker can claim rewards
     * @notice Requires at least one interval to have passed since last claim
     */
    function claimRewards(uint256 tokenId) external {
        StakeInfo storage stake = stakes[tokenId];
        require(stake.isStaked, "NFT not staked");
        require(stake.owner == msg.sender, "Not the owner");
        
        uint256 rewards = calculateRewards(tokenId);
        require(rewards > 0, "No rewards to claim");
        
        stake.lastClaimTime = block.timestamp;
        rewardToken.mintStakeRewards(msg.sender, rewards);
        
        emit RewardsClaimed(msg.sender, tokenId, rewards);
    }

    /**
     * @dev Withdraws a staked NFT and claims any remaining rewards
     * @param tokenId ID of the NFT to withdraw
     * @notice Only the original staker can withdraw the NFT
     * @notice Automatically claims any pending rewards before withdrawal
     */
    function withdrawNFT(uint256 tokenId) external {
        StakeInfo storage stake = stakes[tokenId];
        require(stake.isStaked, "NFT not staked");
        require(stake.owner == msg.sender, "Not the owner");
        
        // Claim any remaining rewards
        uint256 rewards = calculateRewards(tokenId);
        if (rewards > 0) {
            rewardToken.mintStakeRewards(msg.sender, rewards);
            emit RewardsClaimed(msg.sender, tokenId, rewards);
        }
        
        // Clear staking data
        delete stakes[tokenId];
        
        // Return NFT to owner
        nftToken.safeTransferFrom(address(this), msg.sender, tokenId);
        
        emit NFTUnstaked(msg.sender, tokenId);
    }
}