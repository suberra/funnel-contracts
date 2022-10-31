import "./IERC5827Proxy.sol";

interface IFunnel is IERC5827Proxy {
    /**
     * @dev Returns amount of tokens that is available to be transferred, which is the minimum amount between account's balance and renewable allowance.
     */
    function availableBalanceOf(address account)
        external
        view
        returns (uint256);
}
