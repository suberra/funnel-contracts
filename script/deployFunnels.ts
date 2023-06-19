import { ethers } from "hardhat";
import { FunnelFactory } from "../typechain-types";
import networkConfig from "./networkconfig.json";

async function getChainId() {
  const network = await ethers.provider.getNetwork();
  return network.chainId;
}

type Deployment = {
  [chainId: string]: {
    [contractName: string]: string;
  };
};

async function main() {
  const chainId = await getChainId();

  console.log(`Deploying funnels contracts on chain ${chainId}...`);
  console.log(
    `Using deployer: ${await ethers.provider.getSigner().getAddress()}...`
  );

  const {
    supported_tokens,
    contracts,
  }: { supported_tokens: Deployment; contracts: Deployment } = networkConfig;

  if (
    !(chainId in supported_tokens) ||
    !supported_tokens[chainId] ||
    Object.keys(supported_tokens[chainId]).length == 0
  ) {
    console.log(`No tokens supported in ${chainId}`);
    return;
  }

  if (
    !(chainId in contracts) ||
    !contracts[chainId] ||
    Object.keys(contracts[chainId]).length == 0
  ) {
    console.log(`No contracts in ${chainId}`);
    return;
  }

  const tokens: { [symbol: string]: string } = supported_tokens[chainId];
  const deployedContracts: { [symbol: string]: string } = contracts[chainId];

  // Deploy funnels
  const { FunnelFactory: funnelFactoryAddr } = deployedContracts;
  console.log(`Using funnel factory at ${funnelFactoryAddr}...`);
  const funnelFactory = await ethers.getContractAt(
    "FunnelFactory",
    funnelFactoryAddr
  );

  console.log(
    `Deploying funnels for tokens: ${Object.keys(tokens).join(", ")}`
  );
  for (const symbol in tokens) {
    const [funnelAddr, isDeployed] = await deployToken(
      funnelFactory,
      tokens[symbol]
    );
    console.log(
      `${tokens[symbol]} (${symbol}): ${funnelAddr} ${
        isDeployed ? "(deployed)" : ""
      }`
    );
  }
}

async function deployToken(
  funnelFactory: FunnelFactory,
  token: string
): Promise<[string, boolean]> {
  try {
    const funnelAddr = await funnelFactory.getFunnelForToken(token);
    if (funnelAddr) {
      //console.log(`Funnel for ${token} already deployed at ${funnelAddr}`);
      return [funnelAddr, false];
    }
  } catch (err) {
    // console.log("Funnel not deployed, deploying...");
  }

  const tx = await funnelFactory.deployFunnelForToken(token);
  const receipt = await tx.wait();

  const funnelAddr = receipt.events?.[0].address; // Initialized event
  if (!funnelAddr) {
    console.error("Unknown tx", receipt);
    throw new Error("Could not get funnel address from receipt");
  }
  //console.log(`Funnel for ${token} deployed at ${funnelAddr}`);
  return [funnelAddr, true];
}

main();
