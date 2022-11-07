// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/FunnelFactory.sol";

contract FunnelFactoryDeployer is Script {
    // TODO: use create3 to deploy to stable address across chains
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        FunnelFactory factory = new FunnelFactory();

        vm.stopBroadcast();
    }
}
