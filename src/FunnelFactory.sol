// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./IFunnel.sol";
import "./IERC5827.sol";
import "./IERC5827Proxy.sol";

contract FunnelFactory is IFunnelFactory {
    address public erc20FunnelImplementation;
    // tokenAddress => funnelAddress
    mapping(address => address) deployments;

    constructor(address _erc20FunnelImplementation) {
        erc20FunnelImplementation = _erc20FunnelImplementation;
    }

    /**
     * @dev Deploys a new Funnel contract
     * Throws if `_tokenAddress` has already been deployed
     */
    function deployFunnelForToken(address _tokenAddress)
        external
        returns (address _funnelAddress)
    {
        if (deployments[_tokenAddress] != address(0)) {
            revert FunnelAlreadyDeployed();
        }
    }

    function _deployFunnel(address _tokenAddress)
        internal
        returns (address _funnelAddress)
    {}

    /**
     * @dev Returns the Funnel contract address for a given token address
     * Reverts with FunnelNotDeployed if `_tokenAddress` has not been deployed
     */
    function getFunnelForToken(address _tokenAddress)
        external
        view
        returns (address _funnelAddress)
    {
        if (deployments[_tokenAddress] == address(0)) {
            revert FunnelNotDeployed();
        }

        return deployments[_tokenAddress];
    }
}
