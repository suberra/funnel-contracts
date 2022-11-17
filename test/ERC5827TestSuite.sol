// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import { TestSetup } from "./TestSetup.sol";
import "../src/interfaces/IERC5827.sol";

abstract contract ERC5827TestSuite is TestSetup {
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    event RenewableApproval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value,
        uint256 _recoveryRate
    );

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    IERC5827 public renewableToken;

    function testApprove() public {
        // normal approves should still work normally
        vm.prank(user1);
        vm.expectEmit(true, true, false, true);
        emit Approval(user1, user2, 1000);
        vm.expectEmit(true, true, false, true);
        emit RenewableApproval(user1, user2, 1000, 0);
        renewableToken.approve(user2, 1000);
        assertEq(renewableToken.allowance(user1, user2), 1000);

        vm.prank(user2);
        renewableToken.transferFrom(user1, user2, 500);
        assertEq(renewableToken.allowance(user1, user2), 500);

        vm.warp(1000);
        assertEq(renewableToken.allowance(user1, user2), 500);
    }

    function testClearRenewableAllowanceOnNormalApprove() public {
        // we should clear rAllowance on approve(spender, amount)
        // to preserve behavior expected of current ERC20s,
        // i.e. that `approve(addr, x)` will prevent `addr` from spending
        // more than `x` tokens from the user's balance

        // test non-zero re-approve
        vm.prank(user1);
        renewableToken.approveRenewable(user2, 1337, 1);
        assertEq(renewableToken.allowance(user1, user2), 1337);

        vm.prank(user2);
        renewableToken.transferFrom(user1, user2, 1000);
        assertEq(renewableToken.allowance(user1, user2), 337);

        vm.warp(51);
        assertEq(renewableToken.allowance(user1, user2), 387);

        vm.prank(user1);
        renewableToken.approve(user2, 50);

        vm.warp(1237); // 1337 - 50
        assertEq(renewableToken.allowance(user1, user2), 50);

        // test zero re-approve (i.e. revoke)
        vm.prank(user1); // for consistency
        renewableToken.approveRenewable(user2, 1337, 1);
        assertEq(renewableToken.allowance(user1, user2), 1337);

        vm.prank(user2);
        renewableToken.transferFrom(user1, user2, 1000);
        assertEq(renewableToken.allowance(user1, user2), 337);

        vm.prank(user1);
        renewableToken.approve(user2, 0);

        vm.warp(1287);
        assertEq(renewableToken.allowance(user1, user2), 0);
    }

    function testApproveRenewable() public {
        vm.prank(user1);
        vm.expectEmit(true, true, false, true);
        emit RenewableApproval(user1, user2, 1337, 1);
        renewableToken.approveRenewable(user2, 1337, 1);
        assertEq(renewableToken.allowance(user1, user2), 1337);
    }

    function testRenewableAllowanceTransferFrom() public {
        vm.prank(user1);

        // sets renewable allowance
        renewableToken.approveRenewable(user2, 1337, 1);
        assertEq(renewableToken.allowance(user1, user2), 1337);

        vm.startPrank(user2);
        // spend allowance over two transactions
        vm.expectEmit(true, false, false, true);
        emit Transfer(user1, user2, 337);
        renewableToken.transferFrom(user1, user3, 337);
        assertEq(renewableToken.allowance(user1, user2), 1000);

        vm.expectEmit(true, false, false, true);
        emit Transfer(user1, user2, 1000);
        renewableToken.transferFrom(user1, user3, 1000);
        assertEq(renewableToken.allowance(user1, user2), 0);

        // time travel forward by 1000s
        vm.warp(1001);
        // recovered by 1000
        assertEq(renewableToken.allowance(user1, user2), 1000);
        renewableToken.transferFrom(user1, user3, 1000);

        // revert on insufficent allowance
        vm.expectRevert();
        renewableToken.transferFrom(user1, user3, 10);
    }

    function testTransfer() public {
        vm.expectEmit(true, false, false, true);
        emit Transfer(user1, user2, 1337);
        vm.prank(user1);
        renewableToken.transfer(user2, 1337);

        // revert on insufficent balance
        vm.prank(user3);
        vm.expectRevert();
        renewableToken.transfer(user1, 1337);
    }

    function testRenewableMaxAllowance() public {
        vm.prank(user1);

        // sets renewable allowance
        renewableToken.approveRenewable(user2, 1337, 1);
        assertEq(renewableToken.allowance(user1, user2), 1337);

        // time travel forward by 1000s
        vm.warp(1001);

        // allowance doesn't exceed the initial amount
        assertEq(renewableToken.allowance(user1, user2), 1337);
    }

    function testInsufficientAllowance() public {
        vm.prank(user1);
        vm.expectRevert(
            abi.encodePacked(
                IERC5827.InsufficientRenewableAllowance.selector,
                abi.encode(0)
            )
        );
        renewableToken.transferFrom(user1, user3, 10);
    }

    function testRecoveryRateExceeded() public {
        vm.prank(user1);
        vm.expectRevert();
        renewableToken.approveRenewable(user2, 100, 101);
    }

    function testSupportInterface() public view {
        assert(renewableToken.supportsInterface(0x93cd7af6));
    }
}
