# IERC5827Proxy
[Git Source](https://github.com/suberra/funnel-contracts/blob/f73a2b65eed37c0e1e9b0da6edd43d6dee610cb5/src/interfaces/IERC5827Proxy.sol)

**Author:**
Zac (zlace0x), zhongfu (zhongfu), Edison (edison0xyz)


## Functions
### baseToken

Note: the ERC-165 identifier for this interface is 0xc55dae63.
0xc55dae63 ===
bytes4(keccak256('baseToken()')

Get the underlying base token being proxied.


```solidity
function baseToken() external view returns (address);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|address address of the base token|


