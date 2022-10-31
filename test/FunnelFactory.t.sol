// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/FunnelFactory.sol";
import "../src/IFunnelFactory.sol";

contract FunnelFactoryTest is Test {
    FunnelFactory funnelFactory;
    address tokenAddress1;
    address tokenAddress2;
    address tokenAddress3;

    function setUp() public {
        funnelFactory = new FunnelFactory();
        tokenAddress1 = address(0x1111);
        tokenAddress2 = address(0x2222);
        tokenAddress3 = address(0x3333);
    }

    function testDeployFunnelForToken() public {
        address funnelAddress = funnelFactory.deployFunnelForToken(
            tokenAddress1
        );
        assertEq(funnelFactory.getFunnelForToken(tokenAddress1), funnelAddress);
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

    function testDeployFunnelForTokenRevertsIfAlreadyDeployed() public {
        funnelFactory.deployFunnelForToken(tokenAddress3);

        vm.expectRevert(IFunnelFactory.FunnelAlreadyDeployed.selector);
        funnelFactory.deployFunnelForToken(tokenAddress3);
    }

    function testGetFunnelForTokenRevertsIfNotDeployed() public {
        vm.expectRevert(IFunnelFactory.FunnelNotDeployed.selector);
        funnelFactory.getFunnelForToken(tokenAddress3);
    }
}
