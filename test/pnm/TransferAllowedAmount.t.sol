// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { PTest } from "@pwnednomore/contracts/PTest.sol";
import { ERC20PresetFixedSupply, ERC20 } from "openzeppelin-contracts/token/ERC20/presets/ERC20PresetFixedSupply.sol";
import { Funnel } from "../../src/Funnel.sol";

contract TransferAllowedAmountTest is PTest {
    ERC20 internal token;
    Funnel internal funnel;

    address internal user;
    address internal agent;

    function setUp() public {
        user = makeAddr("User");

        token = new ERC20PresetFixedSupply("Existing USDC token", "USDC", type(uint256).max, user);
        funnel = new Funnel();
        funnel.initialize(address(token));

        vm.prank(user);
        token.approve(address(funnel), type(uint256).max);

        agent = getAgent();
    }

    function actionSkip(uint32 _time) external {
        skip(_time);
    }

    function actionApproveRenewable(uint256 _value, uint256 _recoveryRate) external {
        vm.prank(user);
        funnel.approveRenewable(agent, _value, _recoveryRate);
    }

    function invariantCanTransferAllowedAmount() external {
        uint256 maxAmount = token.balanceOf(user);
        uint256 amount = funnel.allowance(user, agent);
        if (amount >= maxAmount) {
            amount = maxAmount;
        }

        uint256 balanceBefore = token.balanceOf(agent);

        vm.prank(agent);
        funnel.transferFrom(user, agent, amount);

        uint256 balanceAfter = token.balanceOf(agent);
        require(balanceAfter == balanceBefore + amount, "incorrect transfer amount");
    }

    function invariantCannotTransferOverAllowedAmount() external {
        uint256 maxAmount = token.balanceOf(user);
        uint256 amount = funnel.allowance(user, agent);
        if (amount >= maxAmount) {
            amount = maxAmount;
        }

        if (amount != type(uint256).max) {
            amount += 1;
        } else {
            return;
        }

        vm.prank(agent);
        vm.expectRevert();
        funnel.transferFrom(user, agent, amount);
    }
}
