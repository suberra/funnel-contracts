// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import { IERC1363Receiver } from "openzeppelin-contracts/interfaces/IERC1363Receiver.sol";
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
        assertTrue(receiver.supportsInterface(IERC1363Receiver.onTransferReceived.selector));
    }

    function testSupportInterfaceSpender() public {
        assertTrue(receiver.supportsInterface(0xb868618d));
        assertTrue(receiver.supportsInterface(IERC5827Spender.onRenewableApprovalReceived.selector));
    }
}
