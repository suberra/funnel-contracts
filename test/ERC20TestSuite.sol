// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import { TestSetup } from "./TestSetup.sol";
import { IERC20 } from "openzeppelin-contracts/interfaces/IERC20.sol";
import { stdStorage, StdStorage } from "forge-std/Test.sol";

abstract contract ERC20TestBase is TestSetup {
    IERC20 public token;
    uint256 mintAmount = 1e76;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function setUp() public virtual override {
        super.setUp();
        mintTokens(user1, mintAmount);
    }

    //////////
    // functions to be overridden
    //////////

    function mintTokens(address to, uint256 amount) public virtual returns (bool);

    //////////
    // util funcs
    //////////

    // transfer()
    function transferTokens(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        vm.prank(from);
        return token.transfer(to, amount);
    }

    function approve(
        address owner,
        address spender,
        uint256 amount
    ) public virtual returns (bool) {
        vm.prank(owner);
        return token.approve(spender, amount);
    }
}

abstract contract ERC20TestTotalSupply is ERC20TestBase {
    function testTotalSupply(uint256 amount) public {
        amount = bound(amount, 0, type(uint256).max / 2);

        uint256 expectedSupply = token.totalSupply() + amount;

        mintTokens(user1, amount);

        assertEq(token.totalSupply(), expectedSupply);
    }
}

abstract contract ERC20TestBalanceOf is ERC20TestBase {
    using stdStorage for StdStorage;

    // does not necessarily have to pass to be compliant
    function testBalanceOfReflectsSlot(uint256 amount) public virtual {
        uint256 slot = stdstore
            .target(address(token))
            .sig(token.balanceOf.selector)
            .with_key(user2)
            .find();

        vm.store(address(token), bytes32(slot), bytes32(amount));

        assertEq(token.balanceOf(user2), amount);
        assertEq(token.balanceOf(user3), 0);
    }

    function testBalanceOfOnMint(uint256 amount) public {
        amount = bound(amount, 0, type(uint256).max / 2);
        uint256 expectedBalance = token.balanceOf(user2) + amount;

        mintTokens(user2, amount);

        assertEq(token.balanceOf(user2), expectedBalance);
        assertEq(token.balanceOf(user3), 0);
    }

    function testBalanceOfOnMintLargeAmount() public {
        testBalanceOfOnMint(type(uint256).max / 2);
    }

    function testBalanceOfOnTransfer(uint256 mintAmount, uint256 transferAmount) public {
        transferAmount = bound(transferAmount, 0, type(uint256).max / 2);
        mintAmount = bound(mintAmount, transferAmount, type(uint256).max / 2);
        mintTokens(user2, mintAmount);

        uint256 expectedBalanceUser1 = token.balanceOf(user1);
        uint256 expectedBalanceUser2 = token.balanceOf(user2) - transferAmount;
        uint256 expectedBalanceUser3 = token.balanceOf(user3) + transferAmount;

        transferTokens(user2, user3, transferAmount);

        assertEq(token.balanceOf(user1), expectedBalanceUser1);
        assertEq(token.balanceOf(user2), expectedBalanceUser2);
        assertEq(token.balanceOf(user3), expectedBalanceUser3);
    }

    function testBalanceOfOnTransferLargeAmount() public {
        testBalanceOfOnTransfer(type(uint256).max / 2, type(uint256).max / 2);
    }
}

abstract contract ERC20TestTransfer is ERC20TestBase {
    function transferWorksCorrectly(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool success) {
        uint256 fromBalance = token.balanceOf(from);
        uint256 toBalance = token.balanceOf(to);

        vm.expectEmit(true, true, false, true);
        emit Transfer(from, to, amount);
        success = transferTokens(from, to, amount);

        assertTrue(success);
        assertEq(token.balanceOf(from), fromBalance - amount);
        assertEq(token.balanceOf(to), toBalance + amount);
    }

    function testTransferFullBalance() public {
        transferWorksCorrectly(user1, user2, mintAmount);
    }

    function testTransferHalfBalance() public {
        transferWorksCorrectly(user1, user2, mintAmount / 2);
    }

    function testTransferOneToken() public {
        transferWorksCorrectly(user1, user2, 1);
    }

    function testTransferZeroTokens() public {
        transferWorksCorrectly(user1, user2, 0);
    }

    function testTransferFuzzing(uint256 amount) public {
        amount = bound(amount, 0, mintAmount);

        transferWorksCorrectly(user1, user2, amount);
    }

    function testFailTransferExceedsBalance(uint256 amount) public {
        amount = bound(amount, mintAmount + 1, type(uint256).max / 2);

        transferWorksCorrectly(user1, user2, amount);
    }
}

abstract contract ERC20TestApprove is ERC20TestBase {
    function approveWorksCorrectly(
        address owner,
        address spender,
        uint256 amount
    ) public virtual returns (bool success) {
        vm.expectEmit(true, true, false, true);
        emit Approval(owner, spender, amount);
        success = approve(owner, spender, amount);

        assertTrue(success);
        assertEq(token.allowance(owner, spender), amount);
    }

    function testInitialAllowance() public {
        assertEq(token.allowance(user1, user2), 0);
    }

    function testApproveFuzzing(uint256 amount) public {
        approveWorksCorrectly(user1, user2, amount);

        assertEq(token.allowance(user2, user1), 0);
        assertEq(token.allowance(user1, user3), 0);
    }

    function testApproveWithTransferFuzzing(uint256 approveAmount, uint256 transferAmount)
        public
    {
        vm.assume(approveAmount != type(uint256).max);
        transferAmount = bound(transferAmount, 0, mintAmount);
        approveAmount = bound(approveAmount, transferAmount, type(uint256).max - 1);

        approveWorksCorrectly(user1, user2, approveAmount);

        uint256 allowanceBefore = token.allowance(user1, user2);
        vm.prank(user2);
        bool success = token.transferFrom(user1, user2, transferAmount);
        uint256 allowanceAfter = token.allowance(user1, user2);

        assertTrue(success);
        assertTrue(allowanceBefore - allowanceAfter == transferAmount);
    }

    function testApproveMaxWithTransfer() public {
        approveWorksCorrectly(user1, user2, type(uint256).max);

        vm.prank(user2);
        bool success = token.transferFrom(user1, user2, 31337);
        uint256 allowanceAfter = token.allowance(user1, user2);

        assertTrue(success);
        assertTrue(
            allowanceAfter == type(uint256).max ||
                allowanceAfter == type(uint256).max - 31337
        );
    }

    function testFailApproveWithTransferInsufficientApproval() public {
        approveWorksCorrectly(user1, user2, 5000);

        vm.prank(user2);
        bool success = token.transferFrom(user1, user2, 5001);

        assertFalse(success);
    }

    function testFailApprovewithTransferInsufficientBalance() public {
        approveWorksCorrectly(user1, user2, 1e76 + 1);

        vm.prank(user2);
        bool success = token.transferFrom(user1, user2, 1e76 + 1);

        assertFalse(success);
    }
}

abstract contract ERC20TestSuite is
    ERC20TestTotalSupply,
    ERC20TestBalanceOf,
    ERC20TestTransfer,
    ERC20TestApprove
{}
