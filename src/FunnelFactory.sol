// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./interfaces/IFunnelFactory.sol";
import "./interfaces/IERC5827.sol";
import "./interfaces/IERC5827Proxy.sol";
import "./Funnel.sol";
import { Clones } from "openzeppelin-contracts/proxy/Clones.sol";

contract FunnelFactory is IFunnelFactory {
    using Clones for address;

    // tokenAddress => funnelAddress
    mapping(address => address) deployments;

    address public funnelImplementation;

    constructor(address _funnelImplementation) {
        funnelImplementation = _funnelImplementation;
    }

    /**
     * @dev Deploys a new Funnel contract
     * Throws if `_tokenAddress` has already been deployed
     */
    function deployFunnelForToken(address _tokenAddress)
        public
        returns (address _funnelAddress)
    {
        if (deployments[_tokenAddress] != address(0)) {
            revert FunnelAlreadyDeployed();
        }

        if (_tokenAddress.code.length == 0) revert InvalidToken();

        _funnelAddress = _deployFunnel(_tokenAddress);
        deployments[_tokenAddress] = _funnelAddress;
        emit DeployedFunnel(_tokenAddress, _funnelAddress);
    }

    /**
     * @dev Deploys a funnel contract to an address dependent on token and factory addresses
     */
    function _deployFunnel(address _tokenAddress) internal returns (address) {
        address funnelAddress = funnelImplementation.cloneDeterministic(
            bytes32(uint256(uint160(_tokenAddress)))
        );

        Funnel(funnelAddress).initialize(_tokenAddress);

        return funnelAddress;
    }

    /**
     * @dev Returns the Funnel contract address for a given token address
     * Reverts with FunnelNotDeployed if `_tokenAddress` has not been deployed
     */
    function getFunnelForToken(address _tokenAddress)
        public
        view
        returns (address _funnelAddress)
    {
        if (deployments[_tokenAddress] == address(0)) {
            revert FunnelNotDeployed();
        }

        return deployments[_tokenAddress];
    }

    /**
     * @dev Returns true if contract address is a deployed Funnel contract
     */
    function isFunnel(address _funnelAddress) public view returns (bool) {
        // Not a deployed contract
        if (_funnelAddress.code.length == 0) return false;

        address baseToken = IERC5827Proxy(_funnelAddress).baseToken();

        if (baseToken == address(0)) return false;

        return _funnelAddress == getFunnelForToken(baseToken);
    }
}
