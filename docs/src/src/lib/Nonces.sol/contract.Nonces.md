# Nonces
[Git Source](https://github.com/suberra/funnel-contracts/blob/f73a2b65eed37c0e1e9b0da6edd43d6dee610cb5/src/lib/Nonces.sol)

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


