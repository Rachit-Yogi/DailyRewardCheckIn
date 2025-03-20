pragma solidity ^0.8.0;

contract DailyLoginReward {
    // 1 token = 1 ether (using wei internally)
    uint256 public constant REWARD_AMOUNT = 1 ether;
    // 24 hours in seconds
    uint256 public constant REWARD_INTERVAL = 86400;
    
    // Track last login timestamp for each user
    mapping(address => uint256) public lastLoginTime;
    // Track user balances
    mapping(address => uint256) public balances;
    
    // Event to log rewards
    event RewardClaimed(address indexed user, uint256 amount, uint256 timestamp);
    
    function claimReward() external {
        address user = msg.sender;
        uint256 currentTime = block.timestamp;
        
        // Check if enough time has passed since last reward
        require(
            currentTime >= lastLoginTime[user] + REWARD_INTERVAL,
            "Reward not available yet"
        );
        
        // Update last login time
        lastLoginTime[user] = currentTime;
        // Add reward to user's balance
        balances[user] += REWARD_AMOUNT;
        
        // Emit event
        emit RewardClaimed(user, REWARD_AMOUNT, currentTime);
    }
    
    function withdraw() external {
        address user = msg.sender;
        uint256 amount = balances[user];
        
        require(amount > 0, "No funds to withdraw");
        
        // Reset balance before transfer to prevent re-entrancy
        balances[user] = 0;
        
        // Transfer funds
        (bool success, ) = user.call{value: amount}("");
        require(success, "Transfer failed");
    }
    
    // Allow contract to receive ETH
    receive() external payable {}
}
