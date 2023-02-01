# MetaTxContext
[Git Source](https://github.com/suberra/funnel-contracts/blob/f73a2b65eed37c0e1e9b0da6edd43d6dee610cb5/src/lib/MetaTxContext.sol)

**Inherits:**
Context

**Author:**
Zac (zlace0x), zhongfu (zhongfu), Edison (edison0xyz)

Provides information about the current execution context, including the
sender of the transaction and its data. While these are generally available
via msg.sender and msg.data, they should not be accessed in such a direct
manner, since when dealing with meta-transactions the account sending and
paying for execution may not be the actual sender (as far as an application
is concerned).


## Functions
### _msgSender

Allows the recipient contract to retrieve the original sender
in the case of a meta-transaction sent by the relayer

*Required since the msg.sender in metatx will be the relayer's address*


```solidity
function _msgSender() internal view virtual override returns (address sender);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`sender`|`address`|Address of the original sender|


