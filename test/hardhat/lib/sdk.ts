import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import {
  TypedDataDomain,
  TypedDataField,
} from "@ethersproject/abstract-signer";
import { BigNumber, ethers } from "ethers";

export type PermitData = {
  domain: TypedDataDomain;
  types: Record<string, TypedDataField[]>;
  message: Record<string, any>;
  primaryType?: string;
};

export function generatePeriodicAllowancePermit(
  chainId: number,
  verifyingContract: string,
  owner: string,
  token: string,
  spender: string,
  amount: number | BigNumber,
  durationMin: number,
  startMin: number,
  maxPeriod: number | BigNumber,
  nonce: number | BigNumber,
  deadline: number
): PermitData {
  return {
    types: {
      Permit: [
        { name: "owner", type: "address" },
        { name: "token", type: "address" },
        { name: "spender", type: "address" },
        { name: "amount", type: "uint192" },
        { name: "durationMin", type: "uint24" },
        { name: "startMin", type: "uint40" },
        { name: "maxPeriod", type: "uint24" },
        { name: "nonce", type: "uint256" },
        { name: "deadline", type: "uint256" },
      ],
    },
    primaryType: "Permit",
    domain: {
      name: "PeriodicAllowance",
      version: "1",
      chainId,
      verifyingContract,
    },
    message: {
      owner,
      token,
      spender,
      amount,
      startMin,
      durationMin,
      maxPeriod,
      nonce,
      deadline,
    },
  };
}

export function generateErc20Permit(
  chainId: number,
  verifyingContract: string,
  domainName: string, // from name() -- hopefully it's the same for most ERC20s
  owner: string,
  spender: string,
  value: BigNumber,
  nonce: BigNumber,
  deadline: number
): PermitData {
  return {
    types: {
      Permit: [
        { name: "owner", type: "address" },
        { name: "spender", type: "address" },
        { name: "value", type: "uint256" },
        { name: "nonce", type: "uint256" },
        { name: "deadline", type: "uint256" },
      ],
    },
    primaryType: "Permit",
    domain: {
      name: domainName,
      version: "1", // from version() -- hopefully it's the same for most ERC20s
      chainId,
      verifyingContract,
    },
    message: {
      owner,
      spender,
      value,
      nonce,
      deadline,
    },
  };
}

export function generateMetaTxPermit(
  chainId: number,
  verifyingContract: string,
  domainName: string,
  nonce: BigNumber,
  from: string,
  functionSignature: string
): PermitData {
  return {
    types: {
      MetaTransaction: [
        { name: "nonce", type: "uint256" },
        { name: "from", type: "address" },
        { name: "functionSignature", type: "bytes" },
      ],
    },
    primaryType: "MetaTransaction",
    domain: {
      name: domainName,
      version: "1",
      chainId,
      verifyingContract,
    },
    message: {
      nonce,
      from,
      functionSignature,
    },
  };
}

export async function signPermit(
  permitData: PermitData,
  user: SignerWithAddress
) {
  const digest = await user._signTypedData(
    permitData.domain,
    permitData.types,
    permitData.message
  );

  return ethers.utils.splitSignature(digest);
}
