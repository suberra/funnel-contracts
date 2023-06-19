# Funnels

Funnels are contracts that enforces renewable token allowances [EIP-5827](https://eips.ethereum.org/EIPS/eip-5827) on existing ERC20 tokens, they help rate-limit the amount of tokens that can be transferred in a given time period.

Each funnel contract is a proxy/wrapper for an underlying ERC20 token, funneling a large unlimited allowance to a limited allowance that regains over time. For example, USDC will have its own funnel contract proxy, while another token like WETH will have its own funnel contract.

![Funnels overview](overview.png)

## Factory

The funnel factory is a contract that deploys new funnel contracts, it is the only contract that can create new funnels.

Goal is to deploy a factory onto all supported chains at the same address, and **every chain will produce the same funnel address for the same token address**.

## How does it work?

By using this funnel contract, a sender can approve a spender a spending limit every periodic interval. For example, a subscriber can approve a merchant to deduct up to 100 USDC from his account every month.

1. User first approves the funnel contract to spend using ERC20 approvals
2. User can set renewable allowance on the funnel contract for a given period for an address (spender), approving up to a max limit with a recovery rate.
3. The spender can then withdraw money out of the user's account up to the available allowance on the account.

What is recovery rate? Recovery rate (amount per second) specifies the rate at which the allowance recovers over time. Once a spender spends the money, the available balance first decreases and slowly restores back to the max limit. Unlike conventional finance apps which performs discrete "resets" of spending limit, we implement renewable allowance using a continuous `recoveryRate` as it allows for more flexible use-cases no bound by reset cycles and can be implemented more simply.


## Deployment

Make copy of `.env.template` to `.env` and fill in the values.

Running local fork
`anvil`

Deploy to local fork

`forge script script/FunnelFactoryDeployer.sol:FunnelFactoryDeployer --fork-url http://localhost:8545 --broadcast`

Deploy factory to goerli

`forge script script/FunnelFactoryDeployer.sol:FunnelFactoryDeployer --rpc-url $GOERLI_RPC_URL --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY`

Note: Deployment addresses are dependent on FunnelFactory bytecode and salt used. Multiple deployments will fail.

Deploying individual funnels for ERC20 tokens

Edit `script/networkconfig.json` with correct FunnelFactory, supported ERC20 addresses.

`npx hardhat run script/deployFunnels.ts --network goerli`

## Verification

Private verification
`npx hardhat run script/verifyContracts.ts --network goerli`

## Misc

Run prettier to format the code

```sh
npx prettier --write 'src/**/*.sol'
```

### Gas Report

Forge snapshot automatically captures selected function calls on `.forge-snapshots`. To generate a more comprehensive report, run:

```sh
forge test --gas-report >> .forge-snapshots/report.txt   
forge snapshot # needed for gas checks
```

### Test Coverage

```sh
forge coverage --report lcov   
genhtml lcov.info -o report --branch-coverage 
```

## Documentation

Documentation is generated automatically from the source files through `forge` and will be available at `docs/`. 

To generate the doc and serve automaticaly, run:

```sh
forge doc --serve --port 4000   
```

For more info, refer to [forge-docs](https://book.getfoundry.sh/reference/forge/forge-doc?highlight=doc#forge-doc).


# Deployments

Script for batch deployment across testnet or mainnet
`./script/deployAll.sh`

| Network   | Contract      | Address                                    | Version     |
| --------- | ------------- | ------------------------------------------ | ----------- |
| Goerli    | Funnel (impl) | 0xb2acc9a328039e2918b2d85420251fb831ce47e0 | 0.2.0-alpha |
| Goerli    | FunnelFactory | 0x92324acad3946f0600d7e0e2641ef10d1655d89d | 0.2.0-alpha |
| Goerli    | FunnelFactory | 0x81603CEC57FC0365019E3B06cE3b65F3ff6bcEB7 | 0.4.0-alpha |
| Polygon   | Funnel (impl) | 0xb2acc9a328039e2918b2d85420251fb831ce47e0 | 0.2.0-alpha |
| Polygon   | FunnelFactory | 0x92324acad3946f0600d7e0e2641ef10d1655d89d | 0.2.0-alpha |
| Avalanche | Funnel (impl) | 0xb2acc9a328039e2918b2d85420251fb831ce47e0 | 0.2.0-alpha |
| Avalanche | FunnelFactory | 0x92324acad3946f0600d7e0e2641ef10d1655d89d | 0.2.0-alpha |
| Arbitrum  | Funnel (impl) | 0xb2acc9a328039e2918b2d85420251fb831ce47e0 | 0.2.0-alpha |
| Arbitrum  | FunnelFactory | 0x92324acad3946f0600d7e0e2641ef10d1655d89d | 0.2.0-alpha |
| Mainnet   | FunnelFactory | 0x81603CEC57FC0365019E3B06cE3b65F3ff6bcEB7 | 0.4.0-alpha |
| Mainnet   | Funnel (impl) | 0xB82D6f4b82eA7cF69d6f930DcE8b00B59d5fb036 | 0.4.0-alpha |

# License

MIT @ 2022 Suberra
