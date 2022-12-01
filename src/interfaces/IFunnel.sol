// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import { IERC5827 } from "./IERC5827.sol";
import { IERC5827Payable } from "./IERC5827Payable.sol";
import { IERC5827Proxy } from "./IERC5827Proxy.sol";

interface IFunnel is IERC5827, IERC5827Proxy, IERC5827Payable {
    error RecoveryRateExceeded();
}
