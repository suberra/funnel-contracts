# IFunnelFactory
[Git Source](https://github.com/suberra/funnel-contracts/blob/59c542a5eca5681850b213a7c7430da0cfa78c32/src/interfaces/IFunnelFactory.sol)

**Author:**
Zac (zlace0x), zhongfu (zhongfu), Edison (edison0xyz)


## Functions
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
function getFunnelForToken(address _tokenAddress) external view returns (address _funnelAddress);
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


## Events
### DeployedFunnel
Event emitted when the funnel contract is deployed


```solidity
event DeployedFunnel(address indexed tokenAddress, address indexed funnelAddress);
```

## Errors
### FunnelNotDeployed
==== Factory Errors =====
Error thrown when funnel is not deployed


```solidity
error FunnelNotDeployed();
```

### FunnelAlreadyDeployed
Error thrown when funnel is already deployed.


```solidity
error FunnelAlreadyDeployed();
```

