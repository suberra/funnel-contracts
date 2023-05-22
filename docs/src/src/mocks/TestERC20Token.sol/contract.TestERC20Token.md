# TestERC20Token
[Git Source](https://github.com/suberra/funnel-contracts/blob/59c542a5eca5681850b213a7c7430da0cfa78c32/src/mocks/TestERC20Token.sol)

**Inherits:**
ERC20Permit


## Functions
### constructor


```solidity
constructor(string memory name, string memory symbol, address initialHolder, uint256 initialAmount)
    ERC20(name, symbol)
    ERC20Permit(name);
```

### mint


```solidity
function mint(address to, uint256 amount) public;
```

### burn


```solidity
function burn(address from, uint256 amount) public;
```

### version


```solidity
function version() public pure returns (string memory);
```

