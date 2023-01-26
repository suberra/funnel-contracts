// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import { ERC20PresetFixedSupply, ERC20 } from "openzeppelin-contracts/token/ERC20/presets/ERC20PresetFixedSupply.sol";
import { IERC20Metadata } from "openzeppelin-contracts/interfaces/IERC20Metadata.sol";
import { Funnel, IFunnel, IFunnelErrors } from "../../src/Funnel.sol";
import { EIP712 } from "../../src/lib/EIP712.sol";
import { NativeMetaTransaction } from "../../src/lib/NativeMetaTransaction.sol";
import { ERC5827TestSuite } from "../ERC5827TestSuite.sol";
import { MockSpenderReceiver } from "../../src/mocks/MockSpenderReceiver.sol";
import { MockERC1271 } from "../../src/mocks/MockERC1271.sol";
import { NoNameERC20 } from "../../src/mocks/TestERC20TokenNoName.sol";
import { GasSnapshot } from "forge-gas-snapshot/GasSnapshot.sol";
import { TestSetup } from "../TestSetup.sol";
import { IERC5827 } from "../../src/interfaces/IERC5827.sol";

contract FunnelExtendedTest is TestSetup {
    ERC20 token;
    Funnel funnel;

    function setUp() public override {
        uint256 privateKey = 0xBEEF;
        user1 = vm.addr(privateKey);
        user2 = address(0xCAFE);
        user3 = address(0xDEAD);

        token = new ERC20PresetFixedSupply("Existing USDC token", "USDC", type(uint256).max, user1);

        funnel = new Funnel();
        funnel.initialize(address(token));

        vm.prank(user1);
        // approves proxy contract to handle allowance
        token.approve(address(funnel), type(uint256).max);
    }

    function testRecoveryRateExceededFuzzing(uint256 _amount, uint256 _rate) public {
        vm.assume(_rate > _amount);
        vm.prank(user1);
        vm.expectRevert();
        funnel.approveRenewable(address(user2), _amount, _rate);
    }

    function testApproveRenewableFuzzing(
        uint256 _amount,
        uint256 _rate,
        uint256 _time
    ) public {
        vm.assume(_rate <= _amount);
        vm.assume(_time <= 365 days);
        deal(address(token), user2, 0);

        vm.prank(user1);
        funnel.approveRenewable(user2, _amount, _rate);

        uint256 amountOut1 = funnel.allowance(user1, user2);
        vm.prank(user2);
        funnel.transferFrom(user1, user2, amountOut1);
        require(token.balanceOf(user2) == amountOut1, "incorrect transferred amount");

        skip(_time);

        uint256 maxAmount = token.balanceOf(user1);
        uint256 amountOut2 = funnel.allowance(user1, user2);
        if (amountOut2 >= maxAmount) {
            amountOut2 = maxAmount;
        }
        vm.prank(user2);
        funnel.transferFrom(user1, user2, amountOut2);
        require(token.balanceOf(user2) == amountOut1 + amountOut2, "incorrect transferred amount");
    }
}
