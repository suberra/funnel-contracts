# Funnels

Funnels are contracts that enforces renewable token allowances [EIP-5827](https://ethereum-magicians.org/t/eip-5827-auto-renewable-allowance-extension/10392/3) on existing ERC20 tokens, they help rate-limit the amount of tokens that can be transferred in a given time period.

Each funnel contract is a proxy/wrapper for an underlying ERC20 token, funneling a large unlimited allowance to a limited allowance that regains over time.

### Contracts

1. FunnelFactory.sol - Factory contract for creating funnels

`deployFunnelForToken(address _tokenAddress)` - Deploys the funnel contract for a given token address

`getFunnelForToken(address _tokenAddress)` - Returns the funnel contract address for a given token address


2. ERC20Funnel.sol - Funnel contract for ERC20 tokens

`baseToken()` - Returns the address of the underlying token