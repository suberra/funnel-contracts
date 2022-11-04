// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IFunnelFactory {
    error FunnelNotDeployed();
    error FunnelAlreadyDeployed();

    event DeployedFunnel(
        address indexed tokenAddress,
        address indexed funnelAddress
    );

    /**
     * @dev Deploys a new Funnel contract
     * Throws if `_tokenAddress` has already been deployed
     */
    function deployFunnelForToken(address _tokenAddress)
        external
        returns (address _funnelAddress);

    /**
     * @dev Returns the Funnel contract address for a given token address
     * Throws if `_tokenAddress` has not been deployed
     */
    function getFunnelForToken(address _tokenAddress)
        external
        view
        returns (address _funnelAddress);

    /**
     * @dev Returns true if contract address is a deployed Funnel contract
     */
    function isFunnel(address _funnelAddress) external view returns (bool);
}
