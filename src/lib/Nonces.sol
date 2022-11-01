// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

abstract contract Nonces {
    mapping(address => uint256) internal _nonces;

    /**
     * @notice Nonces for permit / meta-transactions
     * @param owner Token owner's address
     * @return Next nonce
     */
    function nonces(address owner) external view returns (uint256) {
        return _nonces[owner];
    }
}
