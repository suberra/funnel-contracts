// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "openzeppelin-contracts/token/ERC20/presets/ERC20PresetFixedSupply.sol";
import "../src/Funnel.sol";
import "./ERC5827TestSuite.sol";

contract FunnelTest is ERC5827TestSuite {
    ERC20 token;
    Funnel funnel;

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

    function testSupportsInterface2() public view {
        assert(renewableToken.supportsInterface(0xc55dae63));
    }
}
