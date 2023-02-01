# IFunnel
[Git Source](https://github.com/suberra/funnel-contracts/blob/f73a2b65eed37c0e1e9b0da6edd43d6dee610cb5/src/interfaces/IFunnel.sol)

**Inherits:**
[IERC5827](/src/interfaces/IERC5827.sol/contract.IERC5827.md), [IERC5827Proxy](/src/interfaces/IERC5827Proxy.sol/contract.IERC5827Proxy.md), [IERC5827Payable](/src/interfaces/IERC5827Payable.sol/contract.IERC5827Payable.md)

**Author:**
Zac (zlace0x), zhongfu (zhongfu), Edison (edison0xyz)


## Functions
### initialize

Called when the contract is being initialised.

*Sets the INITIAL_CHAIN_ID and INITIAL_DOMAIN_SEPARATOR that might be used in future permit calls*


```solidity
function initialize(address _token) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token`|`address`|contract address of the underlying ERC20 token|


## Errors
### InvalidReturnSelector
*Invalid selector returned*


```solidity
error InvalidReturnSelector();
```

### NotIERC1363Receiver
*Error thrown when attempting to transfer to a non IERC1363Receiver*


```solidity
error NotIERC1363Receiver();
```

### NotIERC5827Spender
*Error thrown when attempting to transfer to a non IERC5827Spender*


```solidity
error NotIERC5827Spender();
```

### RecoveryRateExceeded
*Error thrown if the Recovery Rate exceeds the max allowance*


```solidity
error RecoveryRateExceeded();
```

