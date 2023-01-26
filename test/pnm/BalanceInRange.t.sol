// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { PTest } from "@pwnednomore/contracts/PTest.sol";
import { ERC20PresetFixedSupply, ERC20 } from "openzeppelin-contracts/token/ERC20/presets/ERC20PresetFixedSupply.sol";
import { Funnel, IFunnel, IFunnelErrors } from "../../src/Funnel.sol";

contract BalanceInRangeTest is PTest {
    ERC20 internal token;
    Funnel internal funnel;

    address internal user;
    address internal agent;

    uint256 internal startTime;
    uint256 internal constant AMOUNT = 100e18;
    uint256 internal constant RATE = 100e18;
    uint256 internal constant TIME_LIMIT = 10;
    uint256 internal constant MAX_AMOUNT = RATE * TIME_LIMIT;

    function setUp() public {
        user = makeAddr("User");

        token = new ERC20PresetFixedSupply("Existing USDC token", "USDC", type(uint256).max, user);
        funnel = new Funnel();
        funnel.initialize(address(token));

        vm.prank(user);
        token.approve(address(funnel), type(uint256).max);

        startTime = block.timestamp;

        agent = getAgent();
        vm.prank(user);
        funnel.approveRenewable(agent, AMOUNT, RATE);
    }

    function actionSkip() external {
        if (block.timestamp - startTime < TIME_LIMIT) {
            skip(1);
        }
    }

    function invariantBalanceInRange() external view {
        require(token.balanceOf(agent) <= MAX_AMOUNT, "transfer more than being allowed");
    }
}
