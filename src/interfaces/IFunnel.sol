// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { IERC5827 } from "./IERC5827.sol";
import { IERC5827Payable } from "./IERC5827Payable.sol";
import { IERC5827Proxy } from "./IERC5827Proxy.sol";

/// @title Interface for Funnel contracts for ERC20
/// @author Zac (zlace0x), zhongfu (zhongfu), Edison (edison0xyz)
interface IFunnel is IERC5827, IERC5827Proxy, IERC5827Payable {
    // Error thrown if the Recovery Rate exceeds the max allowance
    error RecoveryRateExceeded();
}
