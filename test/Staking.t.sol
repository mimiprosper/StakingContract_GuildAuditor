// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Staking.sol";

contract StakingTest is Test {
    // initance of the contract
    Staking public staking;

    // setup addresses
    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");

    // deploying the contract
    function setUp() public {
        staking = new Staking();
        // vm.deal(user1, 100 ether);
        vm.deal(user2, 100 ether);
    }

    // fuzzzing --> exposes contracts to a vast range of inputs, 
    // unearthing hidden vulnerabilities.
    function testStake(uint256 amount) public {
        vm.deal(user1, amount);
        vm.prank(user1);
        vm.assume(amount > 0);
        bound(amount, 100 ether, type(uint256).max);

        staking.stake{value: amount}();

        assertEq(staking.stakes(user1), amount);
        assertEq(staking.totalStakes(), amount);
    }

    function testStake_fails_If_ether_Is_zero() public {
        vm.prank(user1);
        vm.expectRevert("Must send ETH to stake");
        staking.stake();
    }

    function testWithdrawal() public {
        vm.startPrank(user1);
        staking.stake{value: 0.1 ether}();
        staking.withdraw(0.1 ether);
        vm.stopPrank();

        assertEq(staking.stakes(user1), 0);
        assertEq(staking.totalStakes(), 0);
    }

       // Invariant --> ensures contracts uphold logical consistency 
    // under various conditions
    function invariant_totalSuppy_Is_Always_zero() public view {
        assertEq(staking.totalStakes(), 0);
    }

    // attack function
    function testReenterWithdraw() public {
        vm.startPrank(address(this));
        vm.deal(address(this), 100 ether);

        staking.stake{value: 10 ether}();

        // test re-enter withdraw
        staking.withdraw(10 ether);
        vm.stopPrank();
    }

    receive() external payable {
        testReenterWithdraw();
    }
}
