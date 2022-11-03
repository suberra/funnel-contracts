// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {IERC1363Receiver} from "openzeppelin-contracts/interfaces/IERC1363Receiver.sol";
import "../src/interfaces/IERC5827Spender.sol";

contract MockSpenderReceiver is IERC1363Receiver, IERC5827Spender {
    function onTransferReceived(
        address,
        address,
        uint256,
        bytes memory
    ) external pure override returns (bytes4) {
        return IERC1363Receiver.onTransferReceived.selector;
    }

    function onRenewableApprovalReceived(
        address,
        uint256,
        uint256,
        bytes memory
    ) external pure override returns (bytes4) {
        return IERC5827Spender.onRenewableApprovalReceived.selector;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        returns (bool)
    {
        return
            interfaceId == type(IERC1363Receiver).interfaceId ||
            interfaceId == type(IERC5827Spender).interfaceId;
    }
}
