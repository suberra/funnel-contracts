// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import { Address } from "openzeppelin-contracts/utils/Address.sol";
import { IERC1363Receiver } from "openzeppelin-contracts/interfaces/IERC1363Receiver.sol";
import { Strings } from "openzeppelin-contracts/utils/Strings.sol";
import { Initializable } from "openzeppelin-contracts/proxy/utils/Initializable.sol";
import { IERC20 } from "openzeppelin-contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "openzeppelin-contracts/token/ERC20/utils/SafeERC20.sol";

import { IFunnel } from "./interfaces/IFunnel.sol";
import { IERC5827 } from "./interfaces/IERC5827.sol";
import { IERC5827Proxy } from "./interfaces/IERC5827Proxy.sol";
import { IERC5827Spender } from "./interfaces/IERC5827Spender.sol";
import { IERC5827Payable } from "./interfaces/IERC5827Payable.sol";
import { MetaTxContext } from "./lib/MetaTxContext.sol";
import { NativeMetaTransaction } from "./lib/NativeMetaTransaction.sol";

contract Funnel is IFunnel, NativeMetaTransaction, MetaTxContext, Initializable {
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////
                            EIP-5827 STORAGE
    //////////////////////////////////////////////////////////////*/

    IERC20 private _baseToken;

    struct RenewableAllowance {
        uint256 maxAmount;
        uint256 remaining;
        uint192 recoveryRate;
        uint64 lastUpdated;
    }

    // owner => spender => renewableAllowance
    mapping(address => mapping(address => RenewableAllowance)) rAllowance;

    /*//////////////////////////////////////////////////////////////
                            EIP-2612 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 internal INITIAL_CHAIN_ID;

    bytes32 internal INITIAL_DOMAIN_SEPARATOR;

    bytes32 internal constant PERMIT_RENEWABLE_TYPEHASH =
        keccak256(
            "PermitRenewable(address owner,address spender,uint256 value,uint256 recoveryRate,uint256 nonce,uint256 deadline)"
        );

    bytes32 internal constant PERMIT_TYPEHASH =
        keccak256(
            "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );

    function initialize(address _token) external initializer {
        require(_token != address(0));
        _baseToken = IERC20(_token);

        INITIAL_CHAIN_ID = block.chainid;

        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }

    /**
     * @dev Returns the name of the token or fallsback to token address if not found
     */
    function name() public view returns (string memory) {
        string memory _name;
        (bool success, bytes memory result) = address(_baseToken).staticcall(
            abi.encodeWithSignature("name()")
        );

        if (success && result.length > 0) {
            _name = abi.decode(result, (string));
        } else {
            _name = Strings.toHexString(uint160(address(_baseToken)), 20);
        }

        return string.concat(_name, " (funnel)");
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256(
                        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                    ),
                    keccak256(bytes(name())),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }

    function DOMAIN_SEPARATOR() public view override returns (bytes32) {
        return
            block.chainid == INITIAL_CHAIN_ID
                ? INITIAL_DOMAIN_SEPARATOR
                : computeDomainSeparator();
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        uint256 nonce;
        unchecked {
            nonce = _nonces[owner]++;
        }

        bytes32 hashStruct = keccak256(
            abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonce, deadline)
        );

        _verifySig(owner, hashStruct, v, r, s);

        _approve(owner, spender, value, 0);
    }

    function permitRenewable(
        address owner,
        address spender,
        uint256 value,
        uint256 recoveryRate,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        uint256 nonce;
        unchecked {
            nonce = _nonces[owner]++;
        }

        bytes32 hashStruct = keccak256(
            abi.encode(
                PERMIT_RENEWABLE_TYPEHASH,
                owner,
                spender,
                value,
                recoveryRate,
                nonce,
                deadline
            )
        );

        _verifySig(owner, hashStruct, v, r, s);

        _approve(owner, spender, value, recoveryRate);
    }

    function approve(address _spender, uint256 _value) external returns (bool success) {
        _approve(_msgSender(), _spender, _value, 0);
        return true;
    }

    function approveRenewable(
        address _spender,
        uint256 _value,
        uint256 _recoveryRate
    ) external returns (bool success) {
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

    // @notice fetch remaining allowance between _owner and _spender while accounting for base token allowance.
    function _remainingAllowance(address _owner, address _spender)
        private
        view
        returns (uint256)
    {
        RenewableAllowance memory a = rAllowance[_owner][_spender];
        uint256 baseAllowance = _baseToken.allowance(_owner, address(this));
        uint256 recovered = a.recoveryRate * (block.timestamp - a.lastUpdated);
        uint256 remainingAllowance = a.remaining + recovered;
        uint256 currentAllowance = remainingAllowance > a.maxAmount
            ? a.maxAmount
            : remainingAllowance;
        return currentAllowance > baseAllowance ? baseAllowance : currentAllowance;
    }

    /// @notice fetch approved max amount and recovery rate
    /// @return amount initial and maximum allowance given to spender
    /// @return recoveryRate recovery amount per second
    function renewableAllowance(address _owner, address _spender)
        external
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
            revert InsufficientRenewableAllowance({ available: remainingAllowance });
        }

        if (remainingAllowance != type(uint256).max) {
            rAllowance[from][_msgSender()].remaining = remainingAllowance - amount;
            rAllowance[from][_msgSender()].lastUpdated = uint64(block.timestamp);
        }

        _baseToken.safeTransferFrom(from, to, amount);
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
            "IERC5827Payable: IERC1363Receiver returned wrong data"
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
    ) internal returns (bool) {
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
                revert("IERC5827Payable: transfer to non IERC1363Receiver implementer");
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

        require(
            _checkOnApprovalReceived(_spender, _value, _recoveryRate, data),
            "IERC5827Payable: IERC5827Spender returned wrong data"
        );

        return true;
    }

    function _checkOnApprovalReceived(
        address _spender,
        uint256 _value,
        uint256 _recoveryRate,
        bytes memory data
    ) internal returns (bool) {
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
            return retval == IERC5827Spender.onRenewableApprovalReceived.selector;
        } catch (bytes memory reason) {
            if (reason.length == 0) {
                revert("IERC5827Payable: approve a non IERC5827Spender implementer");
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

    function supportsInterface(bytes4 interfaceId) external pure virtual returns (bool) {
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
        _baseToken.safeTransferFrom(_msgSender(), to, amount);
        return true;
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
            let result := staticcall(gas(), implementation, 0, calldatasize(), 0, 0)

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
