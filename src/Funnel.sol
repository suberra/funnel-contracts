// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {IFunnel} from "./interfaces/IFunnel.sol";
import {IERC5827} from "./interfaces/IERC5827.sol";
import {IERC5827Proxy} from "./interfaces/IERC5827Proxy.sol";
import {IERC5827Spender} from "./interfaces/IERC5827Spender.sol";
import {IERC5827Payable} from "./interfaces/IERC5827Payable.sol";
import {MetaTxContext} from "./lib/MetaTxContext.sol";
import {IERC20} from "openzeppelin-contracts/interfaces/IERC20.sol";

import {Address} from "openzeppelin-contracts/utils/Address.sol";
import {IERC1363Receiver} from "openzeppelin-contracts/interfaces/IERC1363Receiver.sol";

contract Funnel is IFunnel, MetaTxContext {
    IERC20 private immutable _baseToken;

    struct RenewableAllowance {
        uint256 maxAmount;
        uint256 remaining;
        uint192 recoveryRate;
        uint64 lastUpdated;
    }

    // owner => spender => renewableAllowance
    mapping(address => mapping(address => RenewableAllowance)) rAllowance;

    constructor(IERC20 _token) {
        _baseToken = _token;
    }

    function approve(address _spender, uint256 _value)
        public
        override
        returns (bool success)
    {
        _approve(_msgSender(), _spender, _value, 0);
        return true;
    }

    function approveRenewable(
        address _spender,
        uint256 _value,
        uint256 _recoveryRate
    ) public returns (bool success) {
        _approve(_msgSender(), _spender, _value, _recoveryRate);
        return true;
    }

    function _approve(
        address _owner,
        address _spender,
        uint256 _value,
        uint256 _recoveryRate
    ) internal {
        if (_recoveryRate > _value) {
            revert RecoveryRateExceeded();
        }

        rAllowance[_owner][_spender] = RenewableAllowance({
            maxAmount: _value,
            remaining: _value,
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
        uint256 remainingAllowance = a.remaining + recovered;
        return
            remainingAllowance > a.maxAmount ? a.maxAmount : remainingAllowance;
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
        return (a.maxAmount, a.recoveryRate);
    }

    /// @notice transfers base token with renewable allowance logic applied
    /// @param from owner of base token
    /// @param to recipient of base token
    /// @param amount amount to transfer
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        uint256 remainingAllowance = _remainingAllowance(from, _msgSender());
        if (remainingAllowance < amount) {
            revert InsufficientRenewableAllowance({
                available: remainingAllowance
            });
        }

        rAllowance[from][_msgSender()].remaining = remainingAllowance - amount;
        rAllowance[from][_msgSender()].lastUpdated = uint64(block.timestamp);

        _baseToken.transferFrom(from, to, amount);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another and then call `onTransferReceived` on receiver
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 The amount of tokens to be transferred
     * @param data bytes Additional data with no specified format, sent in call to `to`
     * @return true unless throwing
     */
    function transferFromAndCall(
        address from,
        address to,
        uint256 value,
        bytes memory data
    ) external returns (bool) {
        transferFrom(from, to, value);

        require(
            _checkOnTransferReceived(from, to, value, data),
            "IPeriodicAllowance: receiver returned wrong data"
        );
        return true;
    }

    /**
     * @dev Internal function to invoke {IERC1363Receiver-onTransferReceived} on a target address
     *  The call is not executed if the target address is not a contract
     * @param from address Representing the previous owner of the given token amount
     * @param recipient address Target address that will receive the tokens
     * @param value uint256 The amount tokens to be transferred
     * @param data bytes Optional data to send along with the call
     * @return whether the call correctly returned the expected magic value
     */
    function _checkOnTransferReceived(
        address from,
        address recipient,
        uint256 value,
        bytes memory data
    ) internal virtual returns (bool) {
        if (!Address.isContract(recipient)) {
            revert("IERC5827Payable: transfer to non contract address");
        }

        try
            IERC1363Receiver(recipient).onTransferReceived(
                _msgSender(), // operator
                from,
                value,
                data
            )
        returns (bytes4 retval) {
            return retval == IERC1363Receiver.onTransferReceived.selector;
        } catch (bytes memory reason) {
            if (reason.length == 0) {
                revert(
                    "IERC5827Payable: transfer to non IERC1363Receiver implementer"
                );
            } else {
                /// @solidity memory-safe-assembly
                assembly {
                    revert(add(32, reason), mload(reason))
                }
            }
        }
    }

    /**
     * @notice Approve renewable allowance for spender and then call `onRenewableApprovalReceived` on IERC5827Spender
     * @param _spender address The address which will spend the funds
     * @param _value uint256 The amount of tokens to be spent
     * @param _recoveryRate period duration in minutes
     * @param data bytes Additional data with no specified format, sent in call to `spender`
     * @return true unless throwing
     */
    function approveRenewableAndCall(
        address _spender,
        uint256 _value,
        uint256 _recoveryRate,
        bytes calldata data
    ) external returns (bool) {
        _approve(_msgSender(), _spender, _value, _recoveryRate);
        IERC5827Spender(_spender).onRenewableApprovalReceived(
            _msgSender(),
            _value,
            _recoveryRate,
            data
        );
        return true;
    }

    function _checkOnApprovalReceived(
        address _spender,
        uint256 _value,
        uint256 _recoveryRate,
        bytes memory data
    ) internal virtual returns (bool) {
        if (!Address.isContract(_spender)) {
            revert("IERC5827Payable: approve a non contract address");
        }

        try
            IERC5827Spender(_spender).onRenewableApprovalReceived(
                _msgSender(),
                _value,
                _recoveryRate,
                data
            )
        returns (bytes4 retval) {
            return
                retval == IERC5827Spender.onRenewableApprovalReceived.selector;
        } catch (bytes memory reason) {
            if (reason.length == 0) {
                revert(
                    "IERC5827Payable: approve a non IERC5827Spender implementer"
                );
            } else {
                /// @solidity memory-safe-assembly
                assembly {
                    revert(add(32, reason), mload(reason))
                }
            }
        }
    }

    function baseToken() external view returns (address) {
        return address(_baseToken);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        returns (bool)
    {
        return
            interfaceId == type(IERC5827).interfaceId ||
            interfaceId == type(IERC5827Payable).interfaceId ||
            interfaceId == type(IERC5827Proxy).interfaceId;
    }

    /// ERC20 functions
    function balanceOf(address account) external view returns (uint256) {
        return _baseToken.balanceOf(account);
    }

    function totalSupply() external view returns (uint256) {
        return _baseToken.totalSupply();
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        return _baseToken.transferFrom(_msgSender(), to, amount);
    }

    fallback() external {
        _fallback(address(_baseToken));
    }

    // View only fallback
    function _fallback(address implementation) internal virtual {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := staticcall(
                gas(),
                implementation,
                0,
                calldatasize(),
                0,
                0
            )

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }
}