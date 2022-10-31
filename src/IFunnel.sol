// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./IERC5827.sol";
import "./IERC5827Proxy.sol";

interface IFunnel is IERC5827, IERC5827Proxy {
    error RecoveryRateExceeded();
}
