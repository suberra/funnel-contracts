// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

library MathUtil {
    /// @dev returns the sum of two uint256 values, saturating at 2**256 - 1
    function saturatingAdd(uint256 a, uint256 b) internal pure returns (uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return type(uint256).max;
            return c;
        }
    }
}
