// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {IERC20Metadata} from "openzeppelin-contracts/interfaces/IERC20Metadata.sol";
import {ERC20PresetMinterPauser} from "openzeppelin-contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";
import {Funnel} from "../Funnel.sol";

contract MockFunnel {
    ERC20PresetMinterPauser token;
    Funnel funnel;

    constructor() {
        token = new ERC20PresetMinterPauser("USDC token", "USDC");

        funnel = new Funnel();
        funnel.initialize(token);
    }

    function mint(address to, uint256 amount) public {
        token.mint(to, amount);
    }
}
