// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./IFunnelFactory.sol";
import "./IERC5827.sol";
import "./IERC5827Proxy.sol";
import "./Funnel.sol";
import {CREATE3} from "solmate/utils/CREATE3.sol";

contract FunnelFactory is IFunnelFactory {
    // tokenAddress => funnelAddress
    mapping(address => address) deployments;

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
        _funnelAddress = _deployFunnel(_tokenAddress);
        deployments[_tokenAddress] = _funnelAddress;
        emit DeployedFunnel(_tokenAddress, _funnelAddress);
    }

    /**
     * @dev Deploys a funnel contract to an address dependent on token and factory addresses
     */
    function _deployFunnel(address _tokenAddress) internal returns (address) {
        return
            CREATE3.deploy(
                bytes32(uint256(uint160(_tokenAddress))), // tokenAddress as salt
                abi.encodePacked(
                    type(Funnel).creationCode,
                    abi.encode(_tokenAddress) // constructor arg
                ),
                0
            );
    }

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
