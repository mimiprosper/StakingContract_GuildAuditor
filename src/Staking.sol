// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Staking {
    mapping(address => uint256) public stakes;
    uint256 public totalStakes;

    function stake() external payable {
        require(msg.value > 0, "Must send ETH to stake");
        stakes[msg.sender] += msg.value;
        totalStakes += msg.value;
    }

    function withdraw(uint256 amount) external {
        require(getStake(msg.sender) >= amount, "Not enough staked");
        stakes[msg.sender] -= amount;
        totalStakes -= amount;
        (bool success,) = msg.sender.call{value: amount}("");
        require(success, "Failed to withdraw");
    }

    function getStake(address user) public view returns (uint256) {
        return stakes[user];
    }
}
