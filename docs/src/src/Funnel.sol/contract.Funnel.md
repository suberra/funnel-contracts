# Funnel
[Git Source](https://github.com/suberra/funnel-contracts/blob/59c542a5eca5681850b213a7c7430da0cfa78c32/src/Funnel.sol)

**Inherits:**
[IFunnel](/src/interfaces/IFunnel.sol/contract.IFunnel.md), [NativeMetaTransaction](/src/lib/NativeMetaTransaction.sol/contract.NativeMetaTransaction.md), [MetaTxContext](/src/lib/MetaTxContext.sol/contract.MetaTxContext.md), Initializable, [IFunnelErrors](/src/interfaces/IFunnelErrors.sol/contract.IFunnelErrors.md)

**Author:**
Zac (zlace0x), zhongfu (zhongfu), Edison (edison0xyz)

This contract is a funnel for ERC20 tokens. It enforces renewable allowances


## State Variables
### _baseToken
EIP-5827 STORAGE
address of the base token (e.g. USDC, DAI, WETH)


```solidity
IERC20 private _baseToken;
```


### rAllowance

```solidity
mapping(address => mapping(address => RenewableAllowance)) public rAllowance;
```


### INITIAL_CHAIN_ID
EIP-2612 STORAGE
INITIAL_CHAIN_ID to be set during initiailisation

*This value will not change*


```solidity
uint256 internal INITIAL_CHAIN_ID;
```


### INITIAL_DOMAIN_SEPARATOR
INITIAL_DOMAIN_SEPARATOR to be set during initiailisation

*This value will not change*


```solidity
bytes32 internal INITIAL_DOMAIN_SEPARATOR;
```


### PERMIT_RENEWABLE_TYPEHASH
constant for the given struct type that do not need to be runtime computed. Required for EIP712-typed data


```solidity
bytes32 internal constant PERMIT_RENEWABLE_TYPEHASH = keccak256(
    "PermitRenewable(address owner,address spender,uint256 value,uint256 recoveryRate,uint256 nonce,uint256 deadline)"
);
```


### PERMIT_TYPEHASH
constant for the given struct type that do not need to be runtime computed. Required for EIP712-typed data


```solidity
bytes32 internal constant PERMIT_TYPEHASH =
    keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
```


## Functions
### initialize

Called when the contract is being initialised.

*Sets the INITIAL_CHAIN_ID and INITIAL_DOMAIN_SEPARATOR that might be used in future permit calls*


```solidity
function initialize(address _token) external initializer;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_token`|`address`|contract address of the underlying ERC20 token|


### fallback

*Fallback function
implemented entirely in `_fallback`.*


```solidity
fallback() external;
```

### permit

Sets fixed allowance with signed approval.

*The address cannot be zero*


```solidity
function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
    external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`owner`|`address`|The address of the token owner|
|`spender`|`address`|The address of the spender.|
|`value`|`uint256`|fixed amount to approve|
|`deadline`|`uint256`|deadline for the approvals in the future|
|`v`|`uint8`||
|`r`|`bytes32`||
|`s`|`bytes32`||


### permitRenewable

Sets renewable allowance with signed approval.

*The address cannot be zero*


```solidity
function permitRenewable(
    address owner,
    address spender,
    uint256 value,
    uint256 recoveryRate,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`owner`|`address`|The address of the token owner|
|`spender`|`address`|The address of the spender.|
|`value`|`uint256`|fixed amount to approve|
|`recoveryRate`|`uint256`|recovery rate for the renewable allowance|
|`deadline`|`uint256`|deadline for the approvals in the future|
|`v`|`uint8`||
|`r`|`bytes32`||
|`s`|`bytes32`||


### approve

Overridden EIP-20 functions


```solidity
function approve(address _spender, uint256 _value) external returns (bool success);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_spender`|`address`|allowed spender of token|
|`_value`|`uint256`|  allowance given to spender|


### approveRenewable

Grants an allowance of `_value` to `_spender` initially, which recovers over time based on `_recoveryRate` up to a limit of `_value`.
SHOULD throw when `_recoveryRate` is larger than `_value`.
MUST emit `RenewableApproval` event.


```solidity
function approveRenewable(address _spender, uint256 _value, uint256 _recoveryRate) external returns (bool success);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_spender`|`address`|allowed spender of token|
|`_value`|`uint256`|  initial and maximum allowance given to spender|
|`_recoveryRate`|`uint256`|recovery amount per second|


### approveRenewableAndCall

Approve renewable allowance for spender and then call `onRenewableApprovalReceived` on IERC5827Spender


```solidity
function approveRenewableAndCall(address _spender, uint256 _value, uint256 _recoveryRate, bytes calldata data)
    external
    returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_spender`|`address`|address The address which will spend the funds|
|`_value`|`uint256`|uint256 The amount of tokens to be spent|
|`_recoveryRate`|`uint256`|period duration in minutes|
|`data`|`bytes`|bytes Additional data with no specified format, sent in call to `spender`|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|true unless throwing|


### transferFrom

Moves `amount` tokens from `from` to `to` using the
allowance mechanism. `amount` is then deducted from the caller's
allowance factoring in recovery rate logic.
SHOULD throw when there is insufficient allowance


```solidity
function transferFrom(address from, address to, uint256 amount) public returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|token owner address|
|`to`|`address`|token recipient|
|`amount`|`uint256`|amount of token to transfer|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|success True if the function is successful, false if otherwise|


### transferFromAndCall

Note: the ERC-165 identifier for this interface is 0x3717806a
0x3717806a ===
bytes4(keccak256('transferFromAndCall(address,address,uint256,bytes)')) ^
bytes4(keccak256('approveRenewableAndCall(address,uint256,uint256,bytes)')) ^

*Transfer tokens from one address to another and then call IERC1363Receiver `onTransferReceived` on receiver*


```solidity
function transferFromAndCall(address from, address to, uint256 value, bytes memory data) external returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|address The address which you want to send tokens from|
|`to`|`address`|address The address which you want to transfer to|
|`value`|`uint256`|uint256 The amount of tokens to be transferred|
|`data`|`bytes`|bytes Additional data with no specified format, sent in call to `to`|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|success true unless throwing|


### transfer

Transfer tokens from the sender to the recipient


```solidity
function transfer(address to, uint256 amount) external returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`to`|`address`|The address of the recipient|
|`amount`|`uint256`|uint256 The amount of tokens to be transferred|


### renewableAllowance

=================================================================
Getter Functions
=================================================================

fetch approved max amount and recovery rate


```solidity
function renewableAllowance(address _owner, address _spender)
    external
    view
    returns (uint256 amount, uint256 recoveryRate);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_owner`|`address`|The address of the owner|
|`_spender`|`address`|The address of the spender|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`amount`|`uint256`|initial and maximum allowance given to spender|
|`recoveryRate`|`uint256`|recovery amount per second|


### allowance

Returns amounts spendable by `_spender`.


```solidity
function allowance(address _owner, address _spender) external view returns (uint256 remaining);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_owner`|`address`|Address of the owner|
|`_spender`|`address`|spender of token|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`remaining`|`uint256`|allowance at the current point in time|


### baseToken

Note: the ERC-165 identifier for this interface is 0xc55dae63.
0xc55dae63 ===
bytes4(keccak256('baseToken()')


```solidity
function baseToken() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|address address of the base token|


### balanceOf


```solidity
function balanceOf(address account) external view returns (uint256 balance);
```

### totalSupply


```solidity
function totalSupply() external view returns (uint256);
```

### name

Gets the name of the token

*Fallback to token address if not found*


```solidity
function name() public view returns (string memory);
```

### DOMAIN_SEPARATOR

Gets the domain separator

*DOMAIN_SEPARATOR should be unique to the contract and chain to prevent replay attacks from
other domains, and satisfy the requirements of EIP-712*


```solidity
function DOMAIN_SEPARATOR() public view override returns (bytes32);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes32`|bytes32 the domain separator|


### supportsInterface

Query if a contract implements an interface

*Interface identification is specified in ERC-165. See https://eips.ethereum.org/EIPS/eip-165*


```solidity
function supportsInterface(bytes4 interfaceId) external pure returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`interfaceId`|`bytes4`|The interface identifier, as specified in ERC-165|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|`true` if the contract implements `interfaceID`|


### _fallback

=================================================================
Internal Functions
=================================================================

Fallback implementation

*Delegates execution to an implementation contract (i.e. base token)
This is a low level function that doesn't return to its internal call site.
It will return to the external caller whatever the implementation returns.*


```solidity
function _fallback(address implementation) internal view;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`implementation`|`address`|Address to delegate.|


### _approve

Internal function to process the approve
Updates the mapping of `RenewableAllowance`

*recoveryRate must be lesser than the value*


```solidity
function _approve(address _owner, address _spender, uint256 _value, uint256 _recoveryRate) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_owner`|`address`|The address of the owner|
|`_spender`|`address`|The address of the spender|
|`_value`|`uint256`|The amount of tokens to be approved|
|`_recoveryRate`|`uint256`|The amount of tokens to be recovered per second|


### _checkOnTransferReceived

Internal function to invoke {IERC1363Receiver-onTransferReceived} on a target address
The call is not executed if the target address is not a contract


```solidity
function _checkOnTransferReceived(address from, address recipient, uint256 value, bytes memory data) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`from`|`address`|address Representing the previous owner of the given token amount|
|`recipient`|`address`|address Target address that will receive the tokens|
|`value`|`uint256`|uint256 The amount tokens to be transferred|
|`data`|`bytes`|bytes Optional data to send along with the call|


### _checkOnApprovalReceived

Internal function that is called after `approve` function.
`onRenewableApprovalReceived` may revert. Function also checks if the address called is a IERC5827Spender


```solidity
function _checkOnApprovalReceived(address _spender, uint256 _value, uint256 _recoveryRate, bytes memory data)
    internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_spender`|`address`|The address which will spend the funds|
|`_value`|`uint256`|The amount of tokens to be spent|
|`_recoveryRate`|`uint256`|The amount of tokens to be recovered per second|
|`data`|`bytes`|bytes Additional data with no specified format|


### _remainingAllowance

fetch remaining allowance between _owner and _spender while accounting for base token allowance.


```solidity
function _remainingAllowance(address _owner, address _spender) private view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_owner`|`address`|address of the owner|
|`_spender`|`address`|address of spender|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|remaining allowance left|


### _computeDomainSeparator

compute the domain separator that is required for the approve by signature functionality
Stops replay attacks from happening because of approvals on different contracts on different chains

*Reference https://eips.ethereum.org/EIPS/eip-712*


```solidity
function _computeDomainSeparator() internal view returns (bytes32);
```

## Structs
### RenewableAllowance
RenewableAllowance struct that is stored on the contract

*The actual remaining allowance at any point of time must be derived from recoveryRate, lastUpdated and maxAmount.
See getter function for implementation details.*


```solidity
struct RenewableAllowance {
    uint256 maxAmount;
    uint256 remaining;
    uint192 recoveryRate;
    uint64 lastUpdated;
}
```

