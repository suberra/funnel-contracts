#!/bin/bash
source .env

read -r -p "Broadcast onchain? (y/N)" shouldBroadcast
if [[ "$shouldBroadcast" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    broadcast="--broadcast"
else
    broadcast=""
fi

echo "Deploy testnet? (Y/n)"
read isTestnet

if [[ "$isTestnet" = "Y" || "$isTestnet" = "y" || "$isTestnet" = "" ]] 
then
    echo "Deploying testnets..."
    echo "broadcast = $broadcast"
    forge script script/FunnelFactoryDeployer.sol:FunnelFactoryDeployer --rpc-url $GOERLI_RPC_URL $broadcast
    forge script script/FunnelFactoryDeployer.sol:FunnelFactoryDeployer --rpc-url $MUMBAI_RPC_URL $broadcast
else
    echo "Deploying mainnets..."
    echo "broadcast = $broadcast"
    forge script script/FunnelFactoryDeployer.sol:FunnelFactoryDeployer --rpc-url $POLYGON_RPC_URL $broadcast
    forge script script/FunnelFactoryDeployer.sol:FunnelFactoryDeployer --rpc-url $AVAX_RPC_URL $broadcast
    forge script script/FunnelFactoryDeployer.sol:FunnelFactoryDeployer --rpc-url $ARBITRUM_RPC_URL $broadcast
fi