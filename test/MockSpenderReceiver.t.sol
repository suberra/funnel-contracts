// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import {IERC1363Receiver} from "openzeppelin-contracts/interfaces/IERC1363Receiver.sol";
import "../src/interfaces/IERC5827Spender.sol";
import "../src/mocks/MockSpenderReceiver.sol";

contract MockSpenderReceiverTest is Test {
    MockSpenderReceiver receiver;
    MockSpenderReceiver spender;

    function setUp() public {
        receiver = new MockSpenderReceiver();
        spender = new MockSpenderReceiver();
    }

    function testSupportInterfaceReceiver() public {
        assertEq(
            receiver.supportsInterface(
                IERC1363Receiver.onTransferReceived.selector
            ),
            true
        );
    }

    function testSupportInterfaceSpender() public {
        assertEq(receiver.supportsInterface(0xb868618d), true);
        assertEq(
            receiver.supportsInterface(
                IERC5827Spender.onRenewableApprovalReceived.selector
            ),
            true
        );
    }
}
