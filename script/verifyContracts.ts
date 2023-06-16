import { ethers, tenderly } from "hardhat";
import * as fs from "fs";

async function getChainId() {
  return ethers.provider.getNetwork().then((n: any) => n.chainId);
}

async function main() {
  const chainId = await getChainId();

  console.log(`Verifying tenderly contracts on chain ${chainId}...`);

  const isDryRun = false;

  let deployment;
  try {
    deployment = JSON.parse(
      fs.readFileSync(
        `./broadcast/FunnelFactoryDeployer.sol/${chainId}${
          isDryRun ? "/dry-run" : ""
        }/run-latest.json`,
        "utf8"
      )
    );
  } catch (error) {
    console.error(error);
    return;
  }

  const { transactions } = deployment;

  const funnelImplAddr = transactions.find(
    (tx: any) => tx.transactionType == "CREATE2" && tx.contractName == "Funnel"
  )?.contractAddress;

  console.log(`funnelImplAddr: ${funnelImplAddr}`);

  const funnelFactoryAddr = transactions.find(
    (tx: any) =>
      tx.transactionType == "CREATE2" && tx.contractName == "FunnelFactory"
  )?.contractAddress;
  console.log(`funnelFactoryAddr: ${funnelFactoryAddr}`);

  console.log(`Verifying on tenderly..`);
  await tenderly.verify({
    name: "Funnel",
    address: funnelImplAddr,
  });

  await tenderly.verify({
    name: "FunnelFactory",
    address: funnelFactoryAddr,
  });

  console.log("To verify to etherscan publicly run this:");
  console.log(`
    forge verify-contract --chain ${chainId} --num-of-optimizations 200 --watch --constructor-args $(cast abi-encode "constructor(address)" "${funnelImplAddr}") \
    --compiler-version v0.8.17 \
    ${funnelFactoryAddr} \
    src/FunnelFactory.sol:FunnelFactory \
    $ETHERSCAN_API_KEY
  `);

  console.log(`
    forge verify-contract --chain ${chainId} --num-of-optimizations 200 --watch --constructor-args $(cast abi-encode "constructor()") \
    --compiler-version v0.8.17 \
    ${funnelImplAddr} \
    src/Funnel.sol:Funnel \
    $ETHERSCAN_API_KEY
  `);

  console.log(`Done`);
}

main();
