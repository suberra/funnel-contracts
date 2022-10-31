pragma solidity ^0.8.13;

interface IFunnelFactory {
    error FunnelNotDeployed();
    error FunnelAlreadyDeployed();

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
}
