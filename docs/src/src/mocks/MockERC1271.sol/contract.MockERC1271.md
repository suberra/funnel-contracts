# MockERC1271
[Git Source](https://github.com/suberra/funnel-contracts/blob/59c542a5eca5681850b213a7c7430da0cfa78c32/src/mocks/MockERC1271.sol)

**Inherits:**
IERC1271


## State Variables
### owner

```solidity
address immutable owner;
```


## Functions
### constructor


```solidity
constructor();
```

### isValidSignature

Verifies that the signer is the owner of the signing contract.


```solidity
function isValidSignature(bytes32 _hash, bytes calldata _signature) external view override returns (bytes4);
```

### splitSignature


```solidity
function splitSignature(bytes memory sig) internal pure returns (uint8, bytes32, bytes32);
```

### recoverSigner

Recover the signer of hash, assuming it's an EOA account

*Only for EthSign signatures*


```solidity
function recoverSigner(bytes32 _hash, bytes memory _signature) internal pure returns (address signer);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_hash`|`bytes32`|      Hash of message that was signed|
|`_signature`|`bytes`| Signature encoded as (bytes32 r, bytes32 s, uint8 v)|


### approveToken


```solidity
function approveToken(IERC20 token, address spender, uint256 amount) public;
```

