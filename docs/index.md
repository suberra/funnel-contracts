# Solidity API

## Funnel

This contract is a funnel for ERC20 tokens. It enforces renewable allowances

### _baseToken

```solidity
contract IERC20 _baseToken
```

EIP-5827 STORAGE

### RenewableAllowance

```solidity
struct RenewableAllowance {
  uint256 maxAmount;
  uint256 remaining;
  uint192 recoveryRate;
  uint64 lastUpdated;
}
```

### rAllowance

```solidity
mapping(address => mapping(address => struct Funnel.RenewableAllowance)) rAllowance
```

### initial_chain_id

```solidity
uint256 initial_chain_id
```

EIP-2612 STORAGE

### initial_domain_separator

```solidity
bytes32 initial_domain_separator
```

### PERMIT_RENEWABLE_TYPEHASH

```solidity
bytes32 PERMIT_RENEWABLE_TYPEHASH
```

### PERMIT_TYPEHASH

```solidity
bytes32 PERMIT_TYPEHASH
```

### initialize

```solidity
function initialize(address _token) external
```

Called when the contract is being initialised.

_Sets the intial_chain_id and initial_domain_separator that might be used in future permit calls_

### fallback

```solidity
fallback() external
```

_Fallback function
implemented entirely in `_fallback`._

### _fallback

```solidity
function _fallback(address implementation) internal virtual
```

Fallback implementation

_Delegates execution to an implementation contract (i.e. base token)
This is a low level function that doesn't return to its internal call site.
It will return to the external caller whatever the implementation returns._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| implementation | address | Address to delegate. |

### permit

```solidity
function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external
```

Sets fixed allowance with signed approval.

_The address cannot be zero_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| owner | address | The address of the token owner |
| spender | address | The address of the spender. |
| value | uint256 | fixed amount to approve |
| deadline | uint256 | deadline for the approvals in the future |
| v | uint8 |  |
| r | bytes32 |  |
| s | bytes32 | valid `secp256k1` signature from `owner` over the EIP712-formatted function arguments. |

### permitRenewable

```solidity
function permitRenewable(address owner, address spender, uint256 value, uint256 recoveryRate, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external
```

Sets renewable allowance with signed approval.

_The address cannot be zero_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| owner | address | The address of the token owner |
| spender | address | The address of the spender. |
| value | uint256 | fixed amount to approve |
| recoveryRate | uint256 | recovery rate for the renewable allowance |
| deadline | uint256 | deadline for the approvals in the future |
| v | uint8 |  |
| r | bytes32 |  |
| s | bytes32 | valid `secp256k1` signature from `owner` over the EIP712-formatted function arguments. |

### approve

```solidity
function approve(address _spender, uint256 _value) external returns (bool success)
```

Approves a spender to spend a fixed amount of token

_this sets an approval with no recovery rate, so the allowance do not get renewed_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _spender | address | The address of the spender |
| _value | uint256 | The amount of tokens that the spender can spend |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| success | bool | true if approval is successful, false otherwise |

### approveRenewable

```solidity
function approveRenewable(address _spender, uint256 _value, uint256 _recoveryRate) external returns (bool success)
```

approves renewable allowance

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _spender | address | The address of the spender |
| _value | uint256 | The amount of tokens that the spender can spend |
| _recoveryRate | uint256 | The rate at which the allowance is renewed |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| success | bool | true if the approval is successful. False if otherwise. |

### allowance

```solidity
function allowance(address _owner, address _spender) external view returns (uint256 remaining)
```

fetch amounts spendable by _spender

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _owner | address | The address of the owner |
| _spender | address | The address of the spender |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| remaining | uint256 | The remaining allowance at the current point in time |

### approveRenewableAndCall

```solidity
function approveRenewableAndCall(address _spender, uint256 _value, uint256 _recoveryRate, bytes data) external returns (bool)
```

Approve renewable allowance for spender and then call `onRenewableApprovalReceived` on IERC5827Spender

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _spender | address | address The address which will spend the funds |
| _value | uint256 | uint256 The amount of tokens to be spent |
| _recoveryRate | uint256 | period duration in minutes |
| data | bytes | bytes Additional data with no specified format, sent in call to `spender` |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | true unless throwing |

### transferFromAndCall

```solidity
function transferFromAndCall(address from, address to, uint256 value, bytes data) external returns (bool)
```

_Transfer tokens from one address to another and then call IERC1363Receiver `onTransferReceived` on receiver_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| from | address | address The address which you want to send tokens from |
| to | address | address The address which you want to transfer to |
| value | uint256 | uint256 The amount of tokens to be transferred |
| data | bytes | bytes Additional data with no specified format, sent in call to `to` |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool |  |

### transfer

```solidity
function transfer(address to, uint256 amount) external returns (bool)
```

Transfer tokens from the sender to the recipient

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| to | address | The address of the recipient |
| amount | uint256 | uint256 The amount of tokens to be transferred |

### renewableAllowance

```solidity
function renewableAllowance(address _owner, address _spender) external view returns (uint256 amount, uint256 recoveryRate)
```

fetch approved max amount and recovery rate

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _owner | address | The address of the owner |
| _spender | address | The address of the spender |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| amount | uint256 | initial and maximum allowance given to spender |
| recoveryRate | uint256 | recovery amount per second |

### baseToken

```solidity
function baseToken() external view returns (address)
```

Gets the address of the base token (i.e. the underlying ERC20 token)

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) external pure virtual returns (bool)
```

Query if a contract implements an interface

_Interface identification is specified in ERC-165. See https://eips.ethereum.org/EIPS/eip-165_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| interfaceId | bytes4 | The interface identifier, as specified in ERC-165 |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | `true` if the contract implements `interfaceID` |

### balanceOf

```solidity
function balanceOf(address account) external view returns (uint256 balance)
```

Retrieves the balance of a given user

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| account | address | Address of the user |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| balance | uint256 | The balance of the user |

### totalSupply

```solidity
function totalSupply() external view returns (uint256)
```

Returns the total supply of the token

### name

```solidity
function name() public view returns (string)
```

Gets the name of the token

_Fallback to token address if not found_

### DOMAIN_SEPARATOR

```solidity
function DOMAIN_SEPARATOR() public view returns (bytes32)
```

DOMAIN_SEPARATOR should be unique to the contract and chain to prevent replay attacks from
other domains, and satisfy the requirements of EIP-712

### transferFrom

```solidity
function transferFrom(address from, address to, uint256 amount) public returns (bool)
```

transfers base token with renewable allowance logic applied

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| from | address | owner of base token |
| to | address | recipient of base token |
| amount | uint256 | amount to transfer |

### _approve

```solidity
function _approve(address _owner, address _spender, uint256 _value, uint256 _recoveryRate) internal
```

### _checkOnTransferReceived

```solidity
function _checkOnTransferReceived(address from, address recipient, uint256 value, bytes data) internal returns (bool)
```

_Internal function to invoke {IERC1363Receiver-onTransferReceived} on a target address
The call is not executed if the target address is not a contract_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| from | address | address Representing the previous owner of the given token amount |
| recipient | address | address Target address that will receive the tokens |
| value | uint256 | uint256 The amount tokens to be transferred |
| data | bytes | bytes Optional data to send along with the call |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | whether the call correctly returned the expected magic value |

### computeDomainSeparator

```solidity
function computeDomainSeparator() internal view virtual returns (bytes32)
```

compute the domain seperator that is required for the approve by signature functionality
Stops replay attacks from happening because of approvals on different contracts on different chains

_Reference https://eips.ethereum.org/EIPS/eip-712_

### _checkOnApprovalReceived

```solidity
function _checkOnApprovalReceived(address _spender, uint256 _value, uint256 _recoveryRate, bytes data) internal returns (bool)
```

### _remainingAllowance

```solidity
function _remainingAllowance(address _owner, address _spender) private view returns (uint256)
```

fetch remaining allowance between _owner and _spender while accounting for base token allowance.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _owner | address | address of the owner |
| _spender | address | address of spender |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | uint256 | remaining allowance left |

## FunnelFactory

### deployments

```solidity
mapping(address => address) deployments
```

Stores the mapping between tokenAddress => funnelAddress

### funnelImplementation

```solidity
address funnelImplementation
```

address of the implementation. This is immutable due to security as implementation is not
supposed to change after deployment

### constructor

```solidity
constructor(address _funnelImplementation) public
```

Deploys the FunnelFactory contract

_requires a valid funnelImplementation address_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _funnelImplementation | address | The address of the implementation |

### deployFunnelForToken

```solidity
function deployFunnelForToken(address _tokenAddress) external returns (address _funnelAddress)
```

Deploys a new Funnel contract

_Throws if `_tokenAddress` has already been deployed_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _tokenAddress | address | The address of the token |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| _funnelAddress | address | The address of the deployed Funnel contract |

### isFunnel

```solidity
function isFunnel(address _funnelAddress) external view returns (bool)
```

Checks if a given address is a deployed Funnel contract

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _funnelAddress | address | The address that you want to query |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | true if contract address is a deployed Funnel contract |

### getFunnelForToken

```solidity
function getFunnelForToken(address _tokenAddress) public view returns (address _funnelAddress)
```

Retrieves the Funnel contract address for a given token address

_Reverts with FunnelNotDeployed if `_tokenAddress` has not been deployed_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _tokenAddress | address | The address of the token |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| _funnelAddress | address | The address of the deployed Funnel contract |

## IERC5827

### InsufficientRenewableAllowance

```solidity
error InsufficientRenewableAllowance(uint256 available)
```

@dev Thrown when there available allowance is lesser than transfer amount
  @param available Allowance available, 0 if unset

### RenewableApproval

```solidity
event RenewableApproval(address _owner, address _spender, uint256 _value, uint256 _recoveryRate)
```

Emitted when a new renewable allowance is set.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _owner | address | owner of token |
| _spender | address | allowed spender of token |
| _value | uint256 | initial and maximum allowance given to spender |
| _recoveryRate | uint256 | recovery amount per second |

### approveRenewable

```solidity
function approveRenewable(address _spender, uint256 _value, uint256 _recoveryRate) external returns (bool success)
```

Grants an allowance of `_value` to `_spender` initially, which recovers over time based on `_recoveryRate` up to a limit of `_value`.
SHOULD throw when `_recoveryRate` is larger than `_value`.
MUST emit `RenewableApproval` event.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _spender | address | allowed spender of token |
| _value | uint256 | initial and maximum allowance given to spender |
| _recoveryRate | uint256 | recovery amount per second |

### renewableAllowance

```solidity
function renewableAllowance(address _owner, address _spender) external view returns (uint256 amount, uint256 recoveryRate)
```

Returns approved max amount and recovery rate.

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| amount | uint256 | initial and maximum allowance given to spender |
| recoveryRate | uint256 | recovery amount per second |

### approve

```solidity
function approve(address _spender, uint256 _value) external returns (bool success)
```

Grants a (non-increasing) allowance of _value to _spender.
MUST clear set _recoveryRate to 0 on the corresponding renewable allowance, if any.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _spender | address | allowed spender of token |
| _value | uint256 | allowance given to spender |

### transferFrom

```solidity
function transferFrom(address from, address to, uint256 amount) external returns (bool success)
```

Moves `amount` tokens from `from` to `to` using the
allowance mechanism. `amount` is then deducted from the caller's
allowance factoring in recovery rate logic.
SHOULD throw when there is insufficient allowance

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| from | address | token owner address |
| to | address | token recipient |
| amount | uint256 | amount of token to transfer |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| success | bool | True if the function is successful, false if otherwise |

### allowance

```solidity
function allowance(address _owner, address _spender) external view returns (uint256 remaining)
```

Returns amounts spendable by `_spender`.

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _owner | address | Address of the owner |
| _spender | address | spender of token |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| remaining | uint256 | allowance at the current point in time |

## IERC5827Payable

### transferFromAndCall

```solidity
function transferFromAndCall(address from, address to, uint256 value, bytes data) external returns (bool success)
```

_Transfer tokens from one address to another and then call IERC1363Receiver `onTransferReceived` on receiver_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| from | address | address The address which you want to send tokens from |
| to | address | address The address which you want to transfer to |
| value | uint256 | uint256 The amount of tokens to be transferred |
| data | bytes | bytes Additional data with no specified format, sent in call to `to` |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| success | bool | true unless throwing |

### approveRenewableAndCall

```solidity
function approveRenewableAndCall(address _spender, uint256 _value, uint256 _recoveryRate, bytes data) external returns (bool)
```

Approve renewable allowance for spender and then call `onRenewableApprovalReceived` on IERC5827Spender

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _spender | address | address The address which will spend the funds |
| _value | uint256 | uint256 The amount of tokens to be spent |
| _recoveryRate | uint256 | period duration in minutes |
| data | bytes | bytes Additional data with no specified format, sent in call to `spender` |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | true unless throwing |

## IERC5827Proxy

### baseToken

```solidity
function baseToken() external view returns (address)
```

Get the underlying base token being proxied.

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | address | address address of the base token |

## IERC5827Spender

_Allow transfer/approval call chaining inspired by https://eips.ethereum.org/EIPS/eip-1363_

### onRenewableApprovalReceived

```solidity
function onRenewableApprovalReceived(address owner, uint256 amount, uint256 recoveryRate, bytes data) external returns (bytes4)
```

Handle the approval of IERC5827Payable tokens

_IERC5827Payable calls this function on the recipient
after an `approve`. This function MAY throw to revert and reject the
approval. Return of other than the magic value MUST result in the
transaction being reverted.
Note: the token contract address is always the message sender._

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| owner | address | address owner of the funds |
| amount | uint256 | uint256 The initial and maximum amount of tokens to be spent |
| recoveryRate | uint256 | uint256 amount recovered per second |
| data | bytes | bytes Additional data with no specified format |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bytes4 | `bytes4(keccak256("onRenewableApprovalReceived(address,uint256,uint256,bytes)"))`  unless throwing |

## IFunnel

### RecoveryRateExceeded

```solidity
error RecoveryRateExceeded()
```

## IFunnelFactory

### FunnelNotDeployed

```solidity
error FunnelNotDeployed()
```

Error thrown when funnel is not deployed

### FunnelAlreadyDeployed

```solidity
error FunnelAlreadyDeployed()
```

Error thrown when funnel is already deployed.

### InvalidToken

```solidity
error InvalidToken()
```

Error thrown when the token is invalid

### DeployedFunnel

```solidity
event DeployedFunnel(address tokenAddress, address funnelAddress)
```

Event emitted when the funnel contract is deployed

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| tokenAddress | address | of the base token (indexed) |
| funnelAddress | address | of the deployed funnel contract (indexed) |

### deployFunnelForToken

```solidity
function deployFunnelForToken(address _tokenAddress) external returns (address _funnelAddress)
```

Deploys a new Funnel contract

_Throws if `_tokenAddress` has already been deployed_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _tokenAddress | address | The address of the token |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| _funnelAddress | address | The address of the deployed Funnel contract |

### getFunnelForToken

```solidity
function getFunnelForToken(address _tokenAddress) external view returns (address _funnelAddress)
```

Retrieves the Funnel contract address for a given token address

_Reverts with FunnelNotDeployed if `_tokenAddress` has not been deployed_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _tokenAddress | address | The address of the token |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| _funnelAddress | address | The address of the deployed Funnel contract |

### isFunnel

```solidity
function isFunnel(address _funnelAddress) external view returns (bool)
```

Checks if a given address is a deployed Funnel contract

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _funnelAddress | address | The address that you want to query |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | true if contract address is a deployed Funnel contract |

## EIP712

### DOMAIN_SEPARATOR

```solidity
function DOMAIN_SEPARATOR() public view virtual returns (bytes32)
```

DOMAIN_SEPARATOR should be unique to the contract and chain to prevent replay attacks from
other domains, and satisfy the requirements of EIP-712

### _verifySig

```solidity
function _verifySig(address signer, bytes32 hashStruct, uint8 v, bytes32 r, bytes32 s) internal view returns (bool)
```

Checks if signer's signature matches the data

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| signer | address | address of the signer |
| hashStruct | bytes32 | hash of the typehash & abi encoded data, see https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct] |
| v | uint8 |  |
| r | bytes32 |  |
| s | bytes32 |  |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| [0] | bool | bool true if the signature is valid, false otherwise |

## MathUtil

### saturatingAdd

```solidity
function saturatingAdd(uint256 a, uint256 b) internal pure returns (uint256)
```

_returns the sum of two uint256 values, saturating at 2**256 - 1_

## MetaTxContext

_Provides information about the current execution context, including the
sender of the transaction and its data. While these are generally available
via msg.sender and msg.data, they should not be accessed in such a direct
manner, since when dealing with meta-transactions the account sending and
paying for execution may not be the actual sender (as far as an application
is concerned)._

### _msgSender

```solidity
function _msgSender() internal view virtual returns (address sender)
```

Allows the recipient contract to retrieve the original sender
in the case of a meta-transaction sent by the relayer

_Required since the msg.sender in metatx will be the relayer's address_

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| sender | address | Address of the original sender |

## NativeMetaTransaction

### META_TRANSACTION_TYPEHASH

```solidity
bytes32 META_TRANSACTION_TYPEHASH
```

Precomputed typeHash as defined in EIP712
keccak256("MetaTransaction(uint256 nonce,address from,bytes functionSignature)")

### MetaTransactionExecuted

```solidity
event MetaTransactionExecuted(address userAddress, address payable relayerAddress, bytes functionSignature)
```

Event that is emited if a meta-transaction is emitted

_Useful for off-chain services to pick up these events_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| userAddress | address | Address of the user that sent the meta-transaction |
| relayerAddress | address payable | Address of the relayer that executed the meta-transaction |
| functionSignature | bytes | Signature of the function |

### MetaTransaction

```solidity
struct MetaTransaction {
  uint256 nonce;
  address from;
  bytes functionSignature;
}
```

### executeMetaTransaction

```solidity
function executeMetaTransaction(address userAddress, bytes functionSignature, bytes32 sigR, bytes32 sigS, uint8 sigV) external payable returns (bytes data)
```

Executes a meta transaction in the context of the signer
Allows a relayer to send another user's transaction and pay the gas

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| userAddress | address | Address of the user the sender is performing on behalf of |
| functionSignature | bytes | The signature of the user |
| sigR | bytes32 |  |
| sigS | bytes32 |  |
| sigV | uint8 |  |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| data | bytes | encoded return data of the underlying function call |

### _verifyMetaTx

```solidity
function _verifyMetaTx(address signer, struct NativeMetaTransaction.MetaTransaction metaTx, uint8 v, bytes32 r, bytes32 s) internal view returns (bool isValid)
```

verify if the meta transaction is valid

_Performs some validity check and checks if the signature matches the hash struct
See EIP712.sol for details about `_verifySig`_

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| isValid | bool | bool that is true if the signature is valid. False if otherwise |

## Nonces

### _nonces

```solidity
mapping(address => uint256) _nonces
```

mapping between the user and the nonce of the account

### nonces

```solidity
function nonces(address owner) external view returns (uint256 nonce)
```

Nonce for permit / meta-transactions

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| owner | address | Token owner's address |

#### Return Values

| Name | Type | Description |
| ---- | ---- | ----------- |
| nonce | uint256 | nonce of the owner |

## MockERC1271

### owner

```solidity
address owner
```

### constructor

```solidity
constructor() public
```

### isValidSignature

```solidity
function isValidSignature(bytes32 _hash, bytes _signature) external view returns (bytes4)
```

Verifies that the signer is the owner of the signing contract.

### splitSignature

```solidity
function splitSignature(bytes sig) internal pure returns (uint8, bytes32, bytes32)
```

### recoverSigner

```solidity
function recoverSigner(bytes32 _hash, bytes _signature) internal pure returns (address signer)
```

Recover the signer of hash, assuming it's an EOA account

_Only for EthSign signatures_

#### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _hash | bytes32 | Hash of message that was signed |
| _signature | bytes | Signature encoded as (bytes32 r, bytes32 s, uint8 v) |

### approveToken

```solidity
function approveToken(contract IERC20 token, address spender, uint256 amount) public
```

## MockSpenderReceiver

### TransferReceived

```solidity
event TransferReceived(address operator, address from, uint256 value)
```

### RenewableApprovalReceived

```solidity
event RenewableApprovalReceived(address owner, uint256 value, uint256 recoveryRate)
```

### onTransferReceived

```solidity
function onTransferReceived(address operator, address from, uint256 value, bytes) external returns (bytes4)
```

### onRenewableApprovalReceived

```solidity
function onRenewableApprovalReceived(address owner, uint256 amount, uint256 recoveryRate, bytes) external returns (bytes4)
```

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) public view virtual returns (bool)
```

## TestERC20Token

### constructor

```solidity
constructor(string name, string symbol, address initialHolder, uint256 initialAmount) public
```

### mint

```solidity
function mint(address to, uint256 amount) public
```

### burn

```solidity
function burn(address from, uint256 amount) public
```

### version

```solidity
function version() public pure returns (string)
```

