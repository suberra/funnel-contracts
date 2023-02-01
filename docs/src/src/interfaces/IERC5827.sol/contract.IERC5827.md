# IERC5827
[Git Source](https://github.com/suberra/funnel-contracts/blob/f73a2b65eed37c0e1e9b0da6edd43d6dee610cb5/src/interfaces/IERC5827.sol)

**Inherits:**
IERC20, IERC165

**Author:**
Zac (zlace0x), zhongfu (zhongfu), Edison (edison0xyz)

Please see https://eips.ethereum.org/EIPS/eip-5827 for more details on the goals of this interface


## Functions
### approveRenewable

Grants an allowance of `_value` to `_spender` initially, which recovers over time based on `_recoveryRate` up to a limit of `_value`.
SHOULD throw when `_recoveryRate` is larger than `_value`.
MUST emit `RenewableApproval` event.


```solidity
function approveRenewable(address _spender, uint256 _value, uint256 _recoveryRate) external returns (bool success);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_spender`|`address`|allowed spender of token|
|`_value`|`uint256`|  initial and maximum allowance given to spender|
|`_recoveryRate`|`uint256`|recovery amount per second|


### renewableAllowance

Returns approved max amount and recovery rate.


```solidity
function renewableAllowance(address _owner, address _spender)
    external
    view
    returns (uint256 amount, uint256 recoveryRate);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|initial and maximum allowance given to spender|
|`recoveryRate`|`uint256`|recovery amount per second|


### approve

Overridden EIP-20 functions

Grants a (non-increasing) allowance of _value to _spender.
MUST clear set _recoveryRate to 0 on the corresponding renewable allowance, if any.


```solidity
function approve(address _spender, uint256 _value) external returns (bool success);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_spender`|`address`|allowed spender of token|
|`_value`|`uint256`|  allowance given to spender|


### transferFrom

Moves `amount` tokens from `from` to `to` using the
allowance mechanism. `amount` is then deducted from the caller's
allowance factoring in recovery rate logic.
SHOULD throw when there is insufficient allowance


```solidity
function transferFrom(address from, address to, uint256 amount) external returns (bool success);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|token owner address|
|`to`|`address`|token recipient|
|`amount`|`uint256`|amount of token to transfer|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`success`|`bool`|True if the function is successful, false if otherwise|


### allowance

Returns amounts spendable by `_spender`.


```solidity
function allowance(address _owner, address _spender) external view returns (uint256 remaining);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_owner`|`address`|Address of the owner|
|`_spender`|`address`|spender of token|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`remaining`|`uint256`|allowance at the current point in time|


## Events
### RenewableApproval
Emitted when a new renewable allowance is set.


```solidity
event RenewableApproval(address indexed _owner, address indexed _spender, uint256 _value, uint256 _recoveryRate);
```

## Errors
### InsufficientRenewableAllowance
Note: the ERC-165 identifier for this interface is 0x93cd7af6.
0x93cd7af6 ===
bytes4(keccak256('approveRenewable(address,uint256,uint256)')) ^
bytes4(keccak256('renewableAllowance(address,address)')) ^
bytes4(keccak256('approve(address,uint256)') ^
bytes4(keccak256('transferFrom(address,address,uint256)') ^
bytes4(keccak256('allowance(address,address)') ^

*Thrown when there available allowance is lesser than transfer amount*


```solidity
error InsufficientRenewableAllowance(uint256 available);
```

