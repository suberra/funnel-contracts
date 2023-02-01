# IFunnelErrors
[Git Source](https://github.com/suberra/funnel-contracts/blob/f73a2b65eed37c0e1e9b0da6edd43d6dee610cb5/src/interfaces/IFunnelErrors.sol)

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

