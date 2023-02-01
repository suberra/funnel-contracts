# IERC5827Spender
[Git Source](https://github.com/suberra/funnel-contracts/blob/f73a2b65eed37c0e1e9b0da6edd43d6dee610cb5/src/interfaces/IERC5827Spender.sol)

**Author:**
Zlace

This interface must be implemented if the spender contract wants to react to an renewable approval

*Allow transfer/approval call chaining inspired by https://eips.ethereum.org/EIPS/eip-1363*


## Functions
### onRenewableApprovalReceived

Note: the ERC-165 identifier for this interface is 0xb868618d.
0xb868618d === bytes4(keccak256("onRenewableApprovalReceived(address,uint256,uint256,bytes)"))

Handle the approval of IERC5827Payable tokens

*IERC5827Payable calls this function on the recipient
after an `approve`. This function MAY throw to revert and reject the
approval. Return of other than the magic value MUST result in the
transaction being reverted.
Note: the token contract address is always the message sender.*


```solidity
function onRenewableApprovalReceived(address owner, uint256 amount, uint256 recoveryRate, bytes memory data)
    external
    returns (bytes4);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`owner`|`address`|address owner of the funds|
|`amount`|`uint256`|uint256 The initial and maximum amount of tokens to be spent|
|`recoveryRate`|`uint256`|uint256 amount recovered per second|
|`data`|`bytes`|bytes Additional data with no specified format|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bytes4`|`bytes4(keccak256("onRenewableApprovalReceived(address,uint256,uint256,bytes)"))` unless throwing|


