# IERC5827Payable
[Git Source](https://github.com/suberra/funnel-contracts/blob/f73a2b65eed37c0e1e9b0da6edd43d6dee610cb5/src/interfaces/IERC5827Payable.sol)

**Inherits:**
IERC165

**Author:**
Zac (zlace0x), zhongfu (zhongfu), Edison (edison0xyz)


## Functions
### transferFromAndCall

Note: the ERC-165 identifier for this interface is 0x3717806a
0x3717806a ===
bytes4(keccak256('transferFromAndCall(address,address,uint256,bytes)')) ^
bytes4(keccak256('approveRenewableAndCall(address,uint256,uint256,bytes)')) ^

*Transfer tokens from one address to another and then call IERC1363Receiver `onTransferReceived` on receiver*


```solidity
function transferFromAndCall(address from, address to, uint256 value, bytes memory data)
    external
    returns (bool success);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|address The address which you want to send tokens from|
|`to`|`address`|address The address which you want to transfer to|
|`value`|`uint256`|uint256 The amount of tokens to be transferred|
|`data`|`bytes`|bytes Additional data with no specified format, sent in call to `to`|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`success`|`bool`|true unless throwing|


### approveRenewableAndCall

Approve renewable allowance for spender and then call `onRenewableApprovalReceived` on IERC5827Spender


```solidity
function approveRenewableAndCall(address _spender, uint256 _value, uint256 _recoveryRate, bytes calldata data)
    external
    returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_spender`|`address`|address The address which will spend the funds|
|`_value`|`uint256`|uint256 The amount of tokens to be spent|
|`_recoveryRate`|`uint256`|period duration in minutes|
|`data`|`bytes`|bytes Additional data with no specified format, sent in call to `spender`|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|true unless throwing|


