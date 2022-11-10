// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {IERC1271} from "openzeppelin-contracts/interfaces/IERC1271.sol";
import {IERC20} from "openzeppelin-contracts/interfaces/IERC20.sol";

contract MockERC1271 is IERC1271 {
    bytes4 public _storedValue;

    function approveAll() public {
        _storedValue = IERC1271(address(this)).isValidSignature.selector;
    }

    function denyAll() public {
        _storedValue = bytes4(0);
    }

    function isValidSignature(bytes32, bytes memory)
        external
        view
        override
        returns (bytes4)
    {
        return _storedValue;
    }

    function approveToken(
        IERC20 token,
        address spender,
        uint256 amount
    ) public {
        token.approve(spender, amount);
    }
}
