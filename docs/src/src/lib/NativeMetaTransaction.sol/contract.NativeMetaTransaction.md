# NativeMetaTransaction
[Git Source](https://github.com/suberra/funnel-contracts/blob/59c542a5eca5681850b213a7c7430da0cfa78c32/src/lib/NativeMetaTransaction.sol)

**Inherits:**
[EIP712](/src/lib/EIP712.sol/contract.EIP712.md), [Nonces](/src/lib/Nonces.sol/contract.Nonces.md)

**Author:**
Zac (zlace0x), zhongfu (zhongfu), Edison (edison0xyz)

Functions that enables meta transactions


## State Variables
### META_TRANSACTION_TYPEHASH
Precomputed typeHash as defined in EIP712
keccak256("MetaTransaction(uint256 nonce,address from,bytes functionSignature)")


```solidity
bytes32 public constant META_TRANSACTION_TYPEHASH = 0x23d10def3caacba2e4042e0c75d44a42d2558aabcf5ce951d0642a8032e1e653;
```


## Functions
### executeMetaTransaction

Executes a meta transaction in the context of the signer
Allows a relayer to send another user's transaction and pay the gas


```solidity
function executeMetaTransaction(
    address userAddress,
    bytes memory functionSignature,
    bytes32 sigR,
    bytes32 sigS,
    uint8 sigV
) external returns (bytes memory data);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`userAddress`|`address`|Address of the user the sender is performing on behalf of|
|`functionSignature`|`bytes`|The signature of the user|
|`sigR`|`bytes32`|Output of the ECDSA signature|
|`sigS`|`bytes32`|Output of the ECDSA signature|
|`sigV`|`uint8`|recovery identifier|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`data`|`bytes`|encoded return data of the underlying function call|


### _verifyMetaTx

verify if the meta transaction is valid

*Performs some validity check and checks if the signature matches the hash struct
See EIP712.sol for details about `_verifySig`*


```solidity
function _verifyMetaTx(address signer, MetaTransaction memory metaTx, uint8 v, bytes32 r, bytes32 s)
    internal
    view
    returns (bool isValid);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`isValid`|`bool`|bool that is true if the signature is valid. False if otherwise|


## Events
### MetaTransactionExecuted
Event that is emitted if a meta-transaction is emitted

*Useful for off-chain services to pick up these events*


```solidity
event MetaTransactionExecuted(
    address indexed userAddress, address payable indexed relayerAddress, bytes functionSignature
);
```

## Errors
### FunctionCallError
*Function call is not successful*


```solidity
error FunctionCallError();
```

### InvalidSigner
*Error thrown when invalid signer*


```solidity
error InvalidSigner();
```

## Structs
### MetaTransaction
Meta transaction structure.
No point of including value field here as if user is doing value transfer then he has the funds to pay for gas
He should call the desired function directly in that case.


```solidity
struct MetaTransaction {
    uint256 nonce;
    address from;
    bytes functionSignature;
}
```

