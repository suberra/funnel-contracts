// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "openzeppelin-contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";
import { IERC20Metadata } from "openzeppelin-contracts/interfaces/IERC20Metadata.sol";
import "../src/Funnel.sol";
import { TestSetup, ERC20TestBase, ERC20TestSuite } from "./ERC20TestSuite.sol";
import "../src/mocks/MockSpenderReceiver.sol";

contract FunnelERC20Test is ERC20TestSuite {
    event TransferReceived(address operator, address from, uint256 value);
    event RenewableApprovalReceived(address owner, uint256 value, uint256 recoveryRate);

    ERC20PresetMinterPauser baseToken;
    Funnel funnel;

    address minter;

    function mintTokens(address to, uint256 amount)
        public
        virtual
        override
        returns (bool success)
    {
        vm.prank(minter);
        baseToken.mint(to, amount);
    }

    function setUp() public override {
        TestSetup.setUp();

        minter = address(0x0123456789012345678901234567890123456789);

        vm.prank(minter);
        baseToken = new ERC20PresetMinterPauser("Test Base Token", "TEST");

        funnel = new Funnel();
        funnel.initialize(baseToken);
        token = funnel;

        vm.prank(user1);
        baseToken.approve(address(funnel), type(uint256).max);
        vm.prank(user2);
        baseToken.approve(address(funnel), type(uint256).max);
        vm.prank(user3);
        baseToken.approve(address(funnel), type(uint256).max);

        ERC20TestBase.setUp();
    }

    // not applicable for us
    function testBalanceOfReflectsSlot(uint256 amount) public override {}
}
