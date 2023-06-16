import { ethers, tenderly } from "hardhat";

async function getChainId() {
  const network = await ethers.provider.getNetwork();
  return network.chainId;
}

/**
 * Deploy a single tx, useful when an inner transaction fails during deployment
 */
async function main() {
  const chainId = await getChainId();
  const signer = ethers.provider.getSigner();
  console.log(`Deploying Tx on chain ${chainId}...`);
  console.log(`Using deployer: ${await signer.getAddress()}...`);

  const tx = {
    from: "",
    to: "",
    data: "",
    nonce: "",
    accessList: [],
  };

  const res = await signer.sendTransaction(tx);

  console.log("Tx:" + res.hash);
}

main();
