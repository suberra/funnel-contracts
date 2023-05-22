# FunnelFactory
[Git Source](https://github.com/suberra/funnel-contracts/blob/59c542a5eca5681850b213a7c7430da0cfa78c32/src/FunnelFactory.sol)

**Inherits:**
[IFunnelFactory](/src/interfaces/IFunnelFactory.sol/contract.IFunnelFactory.md), [IFunnelErrors](/src/interfaces/IFunnelErrors.sol/contract.IFunnelErrors.md)

**Author:**
Zac (zlace0x), zhongfu (zhongfu), Edison (edison0xyz)


## State Variables
### deployments
Stores the mapping between tokenAddress => funnelAddress


```solidity
mapping(address => address) private deployments;
```


### funnelImplementation
address of the implementation. This is immutable due to security as implementation is not
supposed to change after deployment


```solidity
address public immutable funnelImplementation;
```


## Functions
### constructor

Deploys the FunnelFactory contract

*requires a valid funnelImplementation address*


```solidity
constructor(address _funnelImplementation);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_funnelImplementation`|`address`|The address of the implementation|


### deployFunnelForToken

Deploys a new Funnel contract

*Throws if `_tokenAddress` has already been deployed*


```solidity
function deployFunnelForToken(address _tokenAddress) external returns (address _funnelAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenAddress`|`address`|The address of the token|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`_funnelAddress`|`address`|The address of the deployed Funnel contract|


### getFunnelForToken

Retrieves the Funnel contract address for a given token address

*Reverts with FunnelNotDeployed if `_tokenAddress` has not been deployed*


```solidity
function getFunnelForToken(address _tokenAddress) public view returns (address _funnelAddress);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_tokenAddress`|`address`|The address of the token|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`_funnelAddress`|`address`|The address of the deployed Funnel contract|


### isFunnel

Checks if a given address is a deployed Funnel contract


```solidity
function isFunnel(address _funnelAddress) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_funnelAddress`|`address`|The address that you want to query|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`bool`|true if contract address is a deployed Funnel contract|


