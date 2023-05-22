# MockSpenderReceiver
[Git Source](https://github.com/suberra/funnel-contracts/blob/59c542a5eca5681850b213a7c7430da0cfa78c32/src/mocks/MockSpenderReceiver.sol)

**Inherits:**
IERC1363Receiver, [IERC5827Spender](/src/interfaces/IERC5827Spender.sol/contract.IERC5827Spender.md)


## Functions
### onTransferReceived


```solidity
function onTransferReceived(address operator, address from, uint256 value, bytes memory)
    external
    override
    returns (bytes4);
```

### onRenewableApprovalReceived


```solidity
function onRenewableApprovalReceived(address owner, uint256 amount, uint256 recoveryRate, bytes memory)
    external
    override
    returns (bytes4);
```

### supportsInterface


```solidity
function supportsInterface(bytes4 interfaceId) public view virtual returns (bool);
```

## Events
### TransferReceived

```solidity
event TransferReceived(address operator, address from, uint256 value);
```

### RenewableApprovalReceived

```solidity
event RenewableApprovalReceived(address owner, uint256 value, uint256 recoveryRate);
```

