// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./IFunnel.sol";
import "./IERC5827.sol";
import "./IERC5827Proxy.sol";

contract Funnel is IFunnel {
    IERC20 private _baseToken;

    struct RenewableAllowance {
        uint256 amount;
        uint256 spent;
        uint192 recoveryRate;
        uint64 lastUpdated;
    }

    // owner => spender => renewableAllowance
    mapping(address => mapping(address => RenewableAllowance)) rAllowance;

    function initialize(IERC20 _token) public {
        _baseToken = _token;
    }

    function approve(address _spender, uint256 _value)
        public
        override
        returns (bool success)
    {
        _approve(msg.sender, _spender, _value, 0);
        return true;
    }

    function approveRenewable(
        address _spender,
        uint256 _value,
        uint256 _recoveryRate
    ) public returns (bool success) {
        _approve(msg.sender, _spender, _value, _recoveryRate);
        return true;
    }

    function _approve(
        address _owner,
        address _spender,
        uint256 _value,
        uint256 _recoveryRate
    ) internal {
        if (_recoveryRate > _value) {
            revert IFunnel.RecoveryRateExceeded();
        }

        rAllowance[_owner][_spender] = RenewableAllowance({
            amount: _value,
            spent: 0,
            recoveryRate: uint192(_recoveryRate),
            lastUpdated: uint64(block.timestamp)
        });
        emit Approval(_owner, _spender, _value);
        emit RenewableApproval(_owner, _spender, _value, _recoveryRate);
    }

    /// @notice fetch amounts spendable by _spender
    /// @return remaining allowance at the current point in time
    function allowance(address _owner, address _spender)
        public
        view
        returns (uint256 remaining)
    {
        return _remainingAllowance(_owner, _spender);
    }

    function _remainingAllowance(address _owner, address _spender)
        private
        view
        returns (uint256)
    {
        RenewableAllowance memory a = rAllowance[_owner][_spender];

        uint256 recovered = a.recoveryRate * (block.timestamp - a.lastUpdated);
        uint256 remainingAllowance = a.amount - a.spent + recovered;
        return remainingAllowance > a.amount ? a.amount : remainingAllowance;
    }

    /// @notice fetch approved max amount and recovery rate
    /// @return amount initial and maximum allowance given to spender
    /// @return recoveryRate recovery amount per second
    function renewableAllowance(address _owner, address _spender)
        public
        view
        returns (uint256 amount, uint256 recoveryRate)
    {
        RenewableAllowance memory a = rAllowance[_owner][_spender];
        return (a.amount, a.recoveryRate);
    }

    /// @notice transfers base token with renewable allowance logic applied
    /// @param from owner of base token
    /// @param to recipient of base token
    /// @param amount amount to transfer
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool) {
        uint256 remainingAllowance = _remainingAllowance(from, msg.sender);
        require(
            remainingAllowance >= amount,
            "ERC5827: insufficient allowance"
        );

        rAllowance[from][msg.sender].spent =
            rAllowance[from][msg.sender].amount -
            (remainingAllowance - amount);
        rAllowance[from][msg.sender].lastUpdated = uint64(block.timestamp);

        _baseToken.transferFrom(from, to, amount);
        return true;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        returns (bool)
    {
        return
            interfaceId == type(IERC5827).interfaceId ||
            interfaceId == type(IERC5827Proxy).interfaceId;
    }

    /**
     * @notice Returns balance of token for an account
     */
    function balanceOf(address account) external view returns (uint256) {
        return _baseToken.balanceOf(account);
    }

    function totalSupply() external view returns (uint256) {
        return _baseToken.totalSupply();
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        return _baseToken.transferFrom(msg.sender, to, amount);
    }

    function baseToken() external view returns (address) {
        return address(_baseToken);
    }
}
