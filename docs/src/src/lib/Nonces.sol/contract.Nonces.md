# Nonces
[Git Source](https://github.com/suberra/funnel-contracts/blob/59c542a5eca5681850b213a7c7430da0cfa78c32/src/lib/Nonces.sol)

Handles nonces mapping. Required for EIP712-based signatures


## State Variables
### _nonces
mapping between the user and the nonce of the account


```solidity
mapping(address => uint256) internal _nonces;
```


## Functions
### nonces

Nonce for permit / meta-transactions


```solidity
function nonces(address owner) external view returns (uint256 nonce);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`owner`|`address`|Token owner's address|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`nonce`|`uint256`|nonce of the owner|


