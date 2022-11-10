// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {Test} from "forge-std/Test.sol";

abstract contract TestSetup is Test {
    address internal user1;
    address internal user2;
    address internal user3;

    function setUp() public virtual {
        user1 = address(0x1111111111111111111111111111111111111111);
        vm.label(user1, "User1");
        user2 = address(0x2222222222222222222222222222222222222222);
        vm.label(user2, "User2");
        user3 = address(0x3333333333333333333333333333333333333333);
        vm.label(user3, "User3");
    }
}
