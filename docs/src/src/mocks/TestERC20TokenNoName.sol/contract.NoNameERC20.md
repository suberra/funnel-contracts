# NoNameERC20
[Git Source](https://github.com/suberra/funnel-contracts/blob/f73a2b65eed37c0e1e9b0da6edd43d6dee610cb5/src/mocks/TestERC20TokenNoName.sol)

*Implementation of the {IERC20} interface.
This implementation is agnostic to the way tokens are created. This means
that a supply mechanism has to be added in a derived contract using {_mint}.
For a generic mechanism see {ERC20PresetMinterPauser}.
TIP: For a detailed writeup see our guide
https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
to implement supply mechanisms].
We have followed general OpenZeppelin Contracts guidelines: functions revert
instead returning `false` on failure. This behavior is nonetheless
conventional and does not conflict with the expectations of ERC20
applications.
Additionally, an {Approval} event is emitted on calls to {transferFrom}.
This allows applications to reconstruct the allowance for all accounts just
by listening to said events. Other implementations of the EIP may not emit
these events, as it isn't required by the specification.
Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
functions have been added to mitigate the well-known issues around setting
allowances. See {IERC20-approve}.*


## State Variables
### _balances

```solidity
mapping(address => uint256) private _balances;
```


### _allowances

```solidity
mapping(address => mapping(address => uint256)) private _allowances;
```


### _totalSupply

```solidity
uint256 private _totalSupply;
```


### _symbol

```solidity
string private _symbol;
```


## Functions
### constructor

*Sets the values for {name} and {symbol}.
The default value of {decimals} is 18. To select a different value for
{decimals} you should overload it.
All two of these values are immutable: they can only be set once during
construction.*


```solidity
constructor(string memory symbol_);
```

### symbol

*Returns the symbol of the token, usually a shorter version of the
name.*


```solidity
function symbol() public view virtual returns (string memory);
```

### decimals

*Returns the number of decimals used to get its user representation.
For example, if `decimals` equals `2`, a balance of `505` tokens should
be displayed to a user as `5.05` (`505 / 10 ** 2`).
Tokens usually opt for a value of 18, imitating the relationship between
Ether and Wei. This is the value {ERC20} uses, unless this function is
overridden;
NOTE: This information is only used for _display_ purposes: it in
no way affects any of the arithmetic of the contract, including
{IERC20-balanceOf} and {IERC20-transfer}.*


```solidity
function decimals() public view virtual returns (uint8);
```

### totalSupply

*See {IERC20-totalSupply}.*


```solidity
function totalSupply() public view virtual returns (uint256);
```

### balanceOf

*See {IERC20-balanceOf}.*


```solidity
function balanceOf(address account) public view virtual returns (uint256);
```

