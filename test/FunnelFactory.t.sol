// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { console } from "forge-std/console.sol";
import "forge-std/Test.sol";
import { ERC20PresetFixedSupply, ERC20 } from "openzeppelin-contracts/token/ERC20/presets/ERC20PresetFixedSupply.sol";
import { FunnelFactory, IFunnelErrors } from "../src/FunnelFactory.sol";
import { Funnel } from "../src/Funnel.sol";
import { IFunnelFactory } from "../src/interfaces/IFunnelFactory.sol";
import { Clones } from "openzeppelin-contracts/proxy/Clones.sol";
import { GasSnapshot } from "forge-gas-snapshot/GasSnapshot.sol";

contract FunnelFactoryTest is Test, GasSnapshot {
    FunnelFactory funnelFactory;
    address tokenAddress1;
    address tokenAddress2;
    address tokenAddress3;

    ERC20 token;

    address user1;
    address user2;
    address user3;

    Funnel implementation;

    function setUp() public {
        implementation = new Funnel();
        funnelFactory = new FunnelFactory(address(implementation));

        user1 = address(0x1111111111111111111111111111111111111111);
        user2 = address(0x2222222222222222222222222222222222222222);
        user3 = address(0x3333333333333333333333333333333333333333);

        ERC20 t1 = new ERC20PresetFixedSupply("Token 1", "T1", 11111, user1);
        ERC20 t2 = new ERC20PresetFixedSupply("Token 2", "T2", 11111, user1);

        tokenAddress1 = address(t1);
        tokenAddress2 = address(t2);
        tokenAddress3 = address(0x3333);

        token = new ERC20PresetFixedSupply("Existing USDC token", "USDC", 13370, user1);
    }

    function calcExpectedAddress(address tokenAddr) public view returns (address hash) {
        return
            Clones.predictDeterministicAddress(
                address(implementation),
                bytes32(uint256(uint160(tokenAddr))),
                address(funnelFactory)
            );
    }

    function testDeployFunnelForToken() public {
        snapStart("deployFunnelForToken");
        address funnelAddress = funnelFactory.deployFunnelForToken(address(token));
        snapEnd();

        assertEq(funnelFactory.getFunnelForToken(address(token)), funnelAddress);

        assertEq(calcExpectedAddress(address(token)), funnelAddress);
    }

    function testDeployFunnelForDifferentTokens() public {
        address funnelAddress1 = funnelFactory.deployFunnelForToken(tokenAddress1);

        address funnelAddress2 = funnelFactory.deployFunnelForToken(tokenAddress2);
        assertFalse(funnelAddress1 == funnelAddress2);
    }

    function testDeployFunnelFromDifferentFactory() public {
        address funnelAddress1 = funnelFactory.deployFunnelForToken(tokenAddress1);

        FunnelFactory funnelFactory2 = new FunnelFactory(address(implementation));
        address funnelAddress2 = funnelFactory2.deployFunnelForToken(tokenAddress1);

        assertFalse(funnelAddress1 == funnelAddress2);
    }

    function testDeployFunnelForTokenRevertsIfAlreadyDeployed() public {
        funnelFactory.deployFunnelForToken(tokenAddress2);

        vm.expectRevert(IFunnelFactory.FunnelAlreadyDeployed.selector);
        funnelFactory.deployFunnelForToken(tokenAddress2);
    }

    function testGetFunnelForTokenRevertsIfNotDeployed() public {
        vm.expectRevert(IFunnelFactory.FunnelNotDeployed.selector);
        funnelFactory.getFunnelForToken(tokenAddress2);
    }

    function testNoCodeTokenReverts() public {
        vm.expectRevert(IFunnelErrors.InvalidToken.selector);
        funnelFactory.deployFunnelForToken(tokenAddress3);
    }

    function testIsFunnelTrueForDeployedFunnel() public {
        address funnel = funnelFactory.deployFunnelForToken(address(token));
        assertTrue(funnelFactory.isFunnel(funnel));
    }

    function testIsFunnelFalseForUndeployedFunnel() public {
        assertFalse(funnelFactory.isFunnel(address(0x1234)));
    }

    function testIsFunnelFalseForNonFunnel() public {
        assertFalse(funnelFactory.isFunnel(address(token)));
    }

    function testIsFunnelFalseForDeployedFunnelFromDifferentFactory() public {
        address funnel = funnelFactory.deployFunnelForToken(address(token));

        FunnelFactory funnelFactory2 = new FunnelFactory(address(implementation));
        address funnelAddress2 = funnelFactory2.deployFunnelForToken(address(token));

        assertTrue(funnelFactory.isFunnel(funnel));
        assertFalse(funnelFactory.isFunnel(funnelAddress2));
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
