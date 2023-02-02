# IFunnelErrors
[Git Source](https://github.com/suberra/funnel-contracts/blob/59c542a5eca5681850b213a7c7430da0cfa78c32/src/interfaces/IFunnelErrors.sol)

**Author:**
Zac (zlace0x), zhongfu (zhongfu), Edison (edison0xyz)


## Errors
### InvalidAddress
*Invalid address, could be due to zero address*


```solidity
error InvalidAddress(address _input);
```

### InvalidToken
Error thrown when the token is invalid


```solidity
error InvalidToken();
```

### NotContractError
*Thrown when attempting to interact with a non-contract.*


```solidity
error NotContractError();
```

### PermitExpired
*Error thrown when the permit deadline expires*


```solidity
error PermitExpired();
```

