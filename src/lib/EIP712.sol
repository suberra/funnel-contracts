// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import { IERC1271 } from "openzeppelin-contracts/interfaces/IERC1271.sol";

abstract contract EIP712 {
    function DOMAIN_SEPARATOR() public view virtual returns (bytes32);

    /**
     * Checks if signer's signature matches the data
     * @param signer address of the signer
     * @param hashStruct hash of the typehash & abi encoded data, see https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct]
     */
    function _verifySig(
        address signer,
        bytes32 hashStruct,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(signer)
        }

        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR(), hashStruct)
        );

        if (size > 0) {
            // signer is a contract
            require(
                IERC1271(signer).isValidSignature(digest, abi.encodePacked(r, s, v)) ==
                    IERC1271(signer).isValidSignature.selector,
                "IERC1271: invalid signature"
            );
        } else {
            // EOA signer
            address recoveredAddress = ecrecover(digest, v, r, s);

            require(
                recoveredAddress != address(0) && recoveredAddress == signer,
                "EIP712: invalid signature"
            );
        }

        return true;
    }
}
