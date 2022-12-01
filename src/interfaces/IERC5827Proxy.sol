// SPDX-License-Identifier: CC0-1.0
pragma solidity 0.8.17;

interface IERC5827Proxy {
    /*
     * Note: the ERC-165 identifier for this interface is 0xc55dae63.
     * 0xc55dae63 ===
     *   bytes4(keccak256('baseToken()')
     */

    /*
     * @notice Get the underlying base token being proxied.
     * @returns baseToken address of the base token
     */
    function baseToken() external view returns (address);
}
