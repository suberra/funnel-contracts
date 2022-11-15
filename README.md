# Funnels

Funnels are contracts that enforces renewable token allowances [EIP-5827](https://ethereum-magicians.org/t/eip-5827-auto-renewable-allowance-extension/10392/3) on existing ERC20 tokens, they help rate-limit the amount of tokens that can be transferred in a given time period.

Each funnel contract is a proxy/wrapper for an underlying ERC20 token, funneling a large unlimited allowance to a limited allowance that regains over time.

![Funnels overview](overview.png)

## Factory

The funnel factory is a contract that deploys new funnel contracts, it is the only contract that can create new funnels.

Goal is to deploy a factory onto all supported chains at the same address, and **every chain will produce the same funnel address for the same token address**. 

## Contracts

### FunnelFactory.sol - Factory contract for creating funnels

`deployFunnelForToken(address _tokenAddress)` - Deploys the funnel contract for a given token address

`getFunnelForToken(address _tokenAddress)` - Returns the funnel contract address for a given token address

`isFunnel` - Returns true if the funnel contract is a funnel deployed by the factory.

### Funnel.sol - Funnel contract for ERC20 tokens

`baseToken()` - Returns the address of the underlying token


# Usage

## Deployment

Make copy of `.env.template` to `.env` and fill in the values.

Running local fork
`anvil`

Deploy to local fork

`forge script script/FunnelFactoryDeployer.sol:FunnelFactoryDeployer --fork-url http://localhost:8545 --broadcast`

Deploy factory to goerli

`forge script script/FunnelFactoryDeployer.sol:FunnelFactoryDeployer --rpc-url $GOERLI_RPC_URL --broadcast`  

# Deployments

| Network | Contract      | Address                                    |
| ------- | ------------- | ------------------------------------------ |
| Goerli  | Funnel (impl) | 0x962050e8ea6b07b58e761646bfd4848c5af53d50 |
| Goerli  | FunnelFactory | 0xae322b3564ae7f4d72be7fa33c9e307d21358ae0 |
| Goerli  | USDC (funnel) | 0x1f87877f29E5FB0BBDdfB702B710Dc6c3501302c |