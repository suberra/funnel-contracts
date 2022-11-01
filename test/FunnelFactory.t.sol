// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "openzeppelin-contracts/token/ERC20/presets/ERC20PresetFixedSupply.sol";
import "../src/FunnelFactory.sol";
import "../src/interfaces/IFunnelFactory.sol";

contract FunnelFactoryTest is Test {
    FunnelFactory funnelFactory;
    address tokenAddress1;
    address tokenAddress2;
    address tokenAddress3;

    ERC20 token;

    address user1;
    address user2;
    address user3;

    function setUp() public {
        funnelFactory = new FunnelFactory();
        tokenAddress1 = address(0x1111);
        tokenAddress2 = address(0x2222);
        tokenAddress3 = address(0x3333);

        user1 = address(0x1111111111111111111111111111111111111111);
        user2 = address(0x2222222222222222222222222222222222222222);
        user3 = address(0x3333333333333333333333333333333333333333);

        token = new ERC20PresetFixedSupply(
            "Existing USDC token",
            "USDC",
            13370,
            user1
        );
    }

    function testDeployFunnelForToken() public {
        address funnelAddress = funnelFactory.deployFunnelForToken(
            address(token)
        );
        assertEq(
            funnelFactory.getFunnelForToken(address(token)),
            funnelAddress
        );
    }

    function testDeployFunnelForDifferentTokens() public {
        address funnelAddress1 = funnelFactory.deployFunnelForToken(
            tokenAddress1
        );

        address funnelAddress2 = funnelFactory.deployFunnelForToken(
            tokenAddress2
        );
        assertFalse(funnelAddress1 == funnelAddress2);
    }

    function testDeployFunnelFromDifferentFactory() public {
        address funnelAddress1 = funnelFactory.deployFunnelForToken(
            tokenAddress1
        );

        FunnelFactory funnelFactory2 = new FunnelFactory();
        address funnelAddress2 = funnelFactory2.deployFunnelForToken(
            tokenAddress1
        );

        assertFalse(funnelAddress1 == funnelAddress2);
    }

    function testDeployFunnelForTokenRevertsIfAlreadyDeployed() public {
        funnelFactory.deployFunnelForToken(tokenAddress3);

        vm.expectRevert(IFunnelFactory.FunnelAlreadyDeployed.selector);
        funnelFactory.deployFunnelForToken(tokenAddress3);
    }

    function testGetFunnelForTokenRevertsIfNotDeployed() public {
        vm.expectRevert(IFunnelFactory.FunnelNotDeployed.selector);
        funnelFactory.getFunnelForToken(tokenAddress3);
    }

    function testTransferFromFunnel() public {
        funnelFactory.deployFunnelForToken(address(token));

        address funnelAddress = funnelFactory.getFunnelForToken(address(token));

        vm.startPrank(user1);
        token.approve(funnelAddress, 1000);

        Funnel funnel = Funnel(funnelAddress);
        funnel.approveRenewable(user2, 10, 1);
        vm.stopPrank();

        vm.startPrank(user2);
        funnel.transferFrom(user1, user3, 10);

        vm.warp(11); // forward 10s
        funnel.transferFrom(user1, user3, 10);

        assertEq(token.balanceOf(user3), 20);
    }
}
