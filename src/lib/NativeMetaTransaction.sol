// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;
import { EIP712 } from "./EIP712.sol";
import "./Nonces.sol";

abstract contract NativeMetaTransaction is EIP712, Nonces {
    // keccak256("MetaTransaction(uint256 nonce,address from,bytes functionSignature)")
    bytes32 public constant META_TRANSACTION_TYPEHASH =
        0x23d10def3caacba2e4042e0c75d44a42d2558aabcf5ce951d0642a8032e1e653;

    event MetaTransactionExecuted(
        address userAddress,
        address payable relayerAddress,
        bytes functionSignature
    );

    /*
     * Meta transaction structure.
     * No point of including value field here as if user is doing value transfer then he has the funds to pay for gas
     * He should call the desired function directly in that case.
     */
    struct MetaTransaction {
        uint256 nonce;
        address from;
        bytes functionSignature;
    }

    function executeMetaTransaction(
        address userAddress,
        bytes memory functionSignature,
        bytes32 sigR,
        bytes32 sigS,
        uint8 sigV
    ) external payable returns (bytes memory) {
        MetaTransaction memory metaTx = MetaTransaction({
            nonce: _nonces[userAddress]++,
            from: userAddress,
            functionSignature: functionSignature
        });

        _verifyMetaTx(userAddress, metaTx, sigV, sigR, sigS);

        // Append userAddress and relayer address at the end to extract it from calling context
        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returnData) = address(this).call(
            abi.encodePacked(functionSignature, userAddress)
        );

        require(success, "Function call not successful");

        emit MetaTransactionExecuted(userAddress, payable(msg.sender), functionSignature);

        return returnData;
    }

    function _verifyMetaTx(
        address signer,
        MetaTransaction memory metaTx,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal view returns (bool) {
        require(signer != address(0), "NativeMetaTransaction: INVALID_SIGNER");

        bytes32 hashStruct = keccak256(
            abi.encode(
                META_TRANSACTION_TYPEHASH,
                metaTx.nonce,
                metaTx.from,
                keccak256(metaTx.functionSignature)
            )
        );

        return _verifySig(signer, hashStruct, v, r, s);
    }
}
