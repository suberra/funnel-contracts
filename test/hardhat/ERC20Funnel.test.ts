import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { BigNumber } from "ethers";
import { ethers } from "hardhat";
import {
  generateErc20Permit,
  generateRenewablePermit,
  signPermit,
} from "./lib/sdk";

async function getChainId() {
  return ethers.provider.getNetwork().then((n) => n.chainId);
}

const tokenDecimals = 18;
function getTokenAmount(amount: number) {
  return ethers.BigNumber.from(10).pow(tokenDecimals).mul(amount);
}

describe("ERC20Funnel", function () {
  async function deployTokenFixture() {
    // Contracts are deployed using the first signer/account by default
    const [minter, user2, user3, user4] = await ethers.getSigners();

    const Token = await ethers.getContractFactory("TestERC20Token");
    const baseToken = await Token.deploy("Test USDC", "USDC.t");

    const Funnel = await ethers.getContractFactory("Funnel");

    const funnel = await Funnel.deploy();
    await funnel.initialize(baseToken.address);

    // delegate all allowance enforcement to funnel
    await baseToken
      .connect(minter)
      .approve(funnel.address, ethers.constants.MaxUint256);

    const token = await ethers.getContractAt("TestERC20Token", funnel.address);

    return { token, minter, user2, user3, user4, funnel };
  }

  describe("Deployment", function () {
    it("Should set the right name & symbol", async function () {
      const { token } = await loadFixture(deployTokenFixture);

      expect(await token.name()).to.equal("Test USDC(funnel)");
      expect(await token.symbol()).to.equal("USDC.t");
    });

    it("Should mint the minter initial tokens", async function () {
      const { token, minter } = await loadFixture(deployTokenFixture);

      expect(await token.balanceOf(minter.address)).to.equal(
        BigNumber.from(10).pow(26)
      );
    });
  });

  describe("transferFrom", function () {
    it("Should allow transferFrom after approval", async function () {
      const { token, minter, user2, user3, user4 } = await loadFixture(
        deployTokenFixture
      );

      await token.connect(minter).approve(user2.address, 100000);
      await token
        .connect(user2)
        .transferFrom(minter.address, user3.address, 50000);
      await token
        .connect(user2)
        .transferFrom(minter.address, user4.address, 50000);

      expect(await token.balanceOf(user3.address)).to.equal(50000);
      expect(await token.balanceOf(user4.address)).to.equal(50000);
    });
  });

  describe("Permits", function () {
    it("should have the expected DOMAIN_SEPARATOR", async function () {
      const { token, funnel } = await loadFixture(deployTokenFixture);

      const domain = {
        name: await token.name(),
        version: "1",
        chainId: await getChainId(),
        verifyingContract: token.address,
      };

      const hashStruct = ethers.utils._TypedDataEncoder.hashDomain(domain);

      expect(await token.DOMAIN_SEPARATOR()).to.equal(hashStruct);
    }),
      it("Should allow transferFrom after permits", async function () {
        const { token, minter, user2, user3, funnel } = await loadFixture(
          deployTokenFixture
        );

        const deadline =
          (await ethers.provider.getBlock("latest")).timestamp + 60;
        const nonce = await token.nonces(minter.address);
        const name = await token.name();

        const data = generateErc20Permit(
          await getChainId(),
          token.address,
          name,
          minter.address, // owner
          user2.address,
          getTokenAmount(99), // value
          nonce,
          deadline
        );

        const { v, r, s } = await signPermit(data, minter);

        await token.permit(
          minter.address,
          user2.address,
          getTokenAmount(99),
          deadline,
          v,
          r,
          s
        );

        await token
          .connect(user2)
          .transferFrom(minter.address, user3.address, getTokenAmount(99));

        expect(await token.balanceOf(user3.address)).to.equal(
          getTokenAmount(99)
        );
      });

    it("Should allow updates to existing allowance via permits", async function () {
      const { token, minter, user2, user3 } = await loadFixture(
        deployTokenFixture
      );

      await token.connect(minter).approve(user2.address, getTokenAmount(99));

      // update allowance
      {
        const deadline =
          (await ethers.provider.getBlock("latest")).timestamp + 60;
        const nonce = await token.nonces(minter.address);

        const data = generateErc20Permit(
          await getChainId(),
          token.address,
          await token.name(),
          minter.address, // owner
          user2.address,
          getTokenAmount(999), // value
          nonce,
          deadline
        );

        const { v, r, s } = await signPermit(data, minter);

        await token.permit(
          minter.address,
          user2.address,
          getTokenAmount(999),
          deadline,
          v,
          r,
          s
        );
      }

      await token
        .connect(user2)
        .transferFrom(minter.address, user3.address, getTokenAmount(999));

      expect(await token.balanceOf(user3.address)).to.equal(
        getTokenAmount(999)
      );
    });

    it("Should revert transferFrom after permits with invalid nonce", async function () {
      const { token, minter, user2, user3 } = await loadFixture(
        deployTokenFixture
      );

      const deadline =
        (await ethers.provider.getBlock("latest")).timestamp + 60;
      const nonce = await token.nonces(minter.address);

      const data = generateErc20Permit(
        await getChainId(),
        token.address,
        await token.name(),
        minter.address, // owner
        user2.address,
        getTokenAmount(99), // value
        nonce.add(1),
        deadline
      );

      const { v, r, s } = await signPermit(data, minter);

      await expect(
        token.permit(
          minter.address,
          user2.address,
          getTokenAmount(99),
          deadline,
          v,
          r,
          s
        )
      ).to.revertedWith("INVALID_SIGNER");

      await expect(
        token
          .connect(user2)
          .transferFrom(minter.address, user3.address, getTokenAmount(99))
      ).to.be.reverted;

      expect(await token.balanceOf(user3.address)).to.equal(0);
    });

    it("Should allow transferFrom after permitRenewable", async function () {
      const { token, minter, user2, user3, funnel } = await loadFixture(
        deployTokenFixture
      );

      const deadline =
        (await ethers.provider.getBlock("latest")).timestamp + 60;
      const nonce = await token.nonces(minter.address);
      const name = await token.name();

      const data = generateRenewablePermit(
        await getChainId(),
        token.address,
        name,
        minter.address, // owner
        user2.address, //spender
        getTokenAmount(99), // value
        getTokenAmount(1), // recovery
        nonce,
        deadline
      );

      const { v, r, s } = await signPermit(data, minter);

      await funnel.permitRenewable(
        minter.address,
        user2.address,
        getTokenAmount(99),
        getTokenAmount(1),
        deadline,
        v,
        r,
        s
      );

      await token
        .connect(user2)
        .transferFrom(minter.address, user3.address, getTokenAmount(99));

      expect(await token.balanceOf(user3.address)).to.equal(getTokenAmount(99));

      // recovers allowances in 15s
      const newTimestamp =
        (await ethers.provider.getBlock("latest")).timestamp + 15;
      await ethers.provider.send("evm_setNextBlockTimestamp", [newTimestamp]);

      await token
        .connect(user2)
        .transferFrom(minter.address, user3.address, getTokenAmount(15));

      expect(await token.balanceOf(user3.address)).to.equal(
        getTokenAmount(99 + 15)
      );
    });
  });
});
