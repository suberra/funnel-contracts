# EIP712
[Git Source](https://github.com/suberra/funnel-contracts/blob/f73a2b65eed37c0e1e9b0da6edd43d6dee610cb5/src/lib/EIP712.sol)

**Author:**
Zac (zlace0x), zhongfu (zhongfu), Edison (edison0xyz)

https://eips.ethereum.org/EIPS/eip-712


## Functions
### DOMAIN_SEPARATOR

Gets the domain separator

*DOMAIN_SEPARATOR should be unique to the contract and chain to prevent replay attacks from
other domains, and satisfy the requirements of EIP-712*


```solidity
function DOMAIN_SEPARATOR() public view virtual returns (bytes32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes32`|bytes32 the domain separator|


### _verifySig

Checks if signer's signature matches the data


```solidity
function _verifySig(address signer, bytes32 hashStruct, uint8 v, bytes32 r, bytes32 s) internal view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`signer`|`address`|address of the signer|
|`hashStruct`|`bytes32`|hash of the typehash & abi encoded data, see https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct]|
|`v`|`uint8`|recovery identifier|
|`r`|`bytes32`|signature parameter|
|`s`|`bytes32`|signature parameter|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|bool true if the signature is valid, false otherwise|


## Errors
### InvalidSignature
*Invalid signature*


```solidity
error InvalidSignature();
```

### IERC1271InvalidSignature
*Signature is invalid (IERC1271)*


```solidity
error IERC1271InvalidSignature();
```

