// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

/// @title Errors for Funnel contracts and FunnelFactory
/// @author Zac (zlace0x), zhongfu (zhongfu), Edison (edison0xyz)
interface FunnelErrors {
    /// @dev Invalid address, could be due to zero address
    /// @param _input address that caused the error.
    error InvalidAddress(address _input);

    /// Error thrown when the token is invalid
    error InvalidToken();

    /// @dev Wrong data received from IERC1363 Receiver
    error WrongDataReceivedIERC1363Receiver();

    /// @dev Wrong data received from IERC5827Spender
    error WrongDatareceivedIERC5827Spender();

    /// @dev Error thrown if the Recovery Rate exceeds the max allowance
    error RecoveryRateExceeded();

    /// @dev Thrown when attempting to interact with a non-contract
    error NotContractError();

    /// @dev Error thrown when the approval is invalid. Could be due to non contract address
    /// not a IERC5827Spender
    error InvalidData();

    /// @dev Error thrown when the permit deadline expires
    error PermitExpired();

    /// ==== Factory Errors =====

    /// Error thrown when funnel is not deployed
    error FunnelNotDeployed();

    /// Error thrown when funnel is already deployed.
    error FunnelAlreadyDeployed();
}
