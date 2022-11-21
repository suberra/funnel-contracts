// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/FunnelFactory.sol";

contract FunnelFactoryDeployer is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        Funnel implementation = new Funnel{ salt: keccak256("Funnel") }();
        new FunnelFactory{ salt: keccak256("FunnelFactory") }(address(implementation));

        vm.stopBroadcast();
    }
}
