// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "openzeppelin-contracts/token/ERC20/presets/ERC20PresetFixedSupply.sol";
import "../src/Funnel.sol";
import "./ERC5827TestSuite.sol";
import "./MockSpenderReceiver.sol";

contract FunnelTest is ERC5827TestSuite {
    event TransferReceived(address operator, address from, uint256 value);
    event RenewableApprovalReceived(
        address owner,
        uint256 value,
        uint256 recoveryRate
    );

    ERC20 token;
    Funnel funnel;

    MockSpenderReceiver spender;

    function setUp() public override {
        user1 = address(0x1111111111111111111111111111111111111111);
        user2 = address(0x2222222222222222222222222222222222222222);
        user3 = address(0x3333333333333333333333333333333333333333);

        token = new ERC20PresetFixedSupply(
            "Existing USDC token",
            "USDC",
            13370,
            user1
        );

        funnel = new Funnel(token);
        renewableToken = funnel;

        spender = new MockSpenderReceiver();

        vm.prank(user1);
        // approves proxy contract to handle allowance
        token.approve(address(renewableToken), type(uint256).max);
    }

    function testBaseToken() public {
        assertEq(funnel.baseToken(), address(token));
    }

    function testRecoveryRateExceeded2() public {
        vm.prank(user1);
        vm.expectRevert(IFunnel.RecoveryRateExceeded.selector);
        funnel.approveRenewable(user2, 100, 101);
    }

    function testTransferFromAndCall() public {
        vm.prank(user1);
        funnel.approveRenewable(user2, 1337, 1);

        vm.prank(user2);
        vm.expectEmit(true, false, false, true);
        emit TransferReceived(user2, user1, 10);
        funnel.transferFromAndCall(user1, address(spender), 10, "");
    }

    function testApproveRenewableAndCall() public {
        vm.prank(user1);
        vm.expectEmit(true, false, false, true);
        emit RenewableApprovalReceived(user1, 1337, 1);
        funnel.approveRenewableAndCall(address(spender), 1337, 1, "");
    }

    function testSupportsInterfaceProxy() public view {
        assert(funnel.supportsInterface(0xc55dae63));
    }

    function testSupportsInterfacePayable() public view {
        assert(funnel.supportsInterface(0x3717806a));
    }
}
