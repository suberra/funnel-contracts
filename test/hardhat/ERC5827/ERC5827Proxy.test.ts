import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import { BigNumber } from "ethers";

const ZERO_ADDRESS = ethers.constants.AddressZero;

import {
  shouldBehaveLikeERC20,
  shouldBehaveLikeERC20Transfer,
  shouldBehaveLikeERC20Approve,
} from "./ERC20.behavior";
import { shouldBehaveLikeERC5827 } from "./ERC5827.behavior";

function expectRevert(promise: Promise<any>, expectedError: string) {
  return expect(promise).to.be.revertedWith(expectedError);
}

describe("ERC5827Proxy", function () {
  async function deployTokenFixture() {
    const signers = await ethers.getSigners();
    const [initialHolder, recipient, anotherAccount] = signers;

    const Token = await ethers.getContractFactory("TestERC20Token");
    const Funnel = await ethers.getContractFactory("Funnel");

    const name = "My Token";
    const symbol = "MTKN";

    const initialSupply = ethers.BigNumber.from("100");

    const baseToken = await Token.deploy(
      name,
      symbol,
      initialHolder.address,
      initialSupply
    );

    const funnel = await Funnel.deploy();
    await funnel.initialize(baseToken.address);

    for (let i = 0; i < 3; i++)
      baseToken
        .connect(signers[i])
        .approve(funnel.address, ethers.constants.MaxUint256);

    const token = await ethers.getContractAt("TestERC20Token", funnel.address);

    return {
      baseToken,
      token,
      initialHolder,
      initialSupply,
      recipient,
      anotherAccount,
    };
  }

  it("has a name", async function () {
    const { token } = await loadFixture(deployTokenFixture);
    expect(await token.name()).to.not.equal("");
  });

  it("has a symbol", async function () {
    const { token } = await loadFixture(deployTokenFixture);
    expect(await token.symbol()).to.not.equal("");
  });

  it("has 18 decimals", async function () {
    const { token } = await loadFixture(deployTokenFixture);
    expect(await token.decimals()).to.be.equal(ethers.BigNumber.from("18"));
  });

  describe("ERC20", async function () {
    const context = await loadFixture(deployTokenFixture);
    shouldBehaveLikeERC20(
      "ERC20",
      context,
      context.initialSupply,
      context.initialHolder.address,
      context.recipient.address,
      context.anotherAccount.address
    );
  });

  describe("decrease allowance", function () {
    describe("when the spender is not the zero address", async function () {
      const {
        recipient: spender,
        token,
        initialHolder,
        initialSupply,
      } = await loadFixture(deployTokenFixture);

      function shouldDecreaseApproval(amount: BigNumber) {
        describe("when there was no approved amount before", function () {
          it("reverts", async function () {
            await expectRevert(
              token.decreaseAllowance(spender.address, amount, {
                from: initialHolder.address,
              }),
              "ERC20: decreased allowance below zero"
            );
          });
        });

        describe("when the spender had an approved amount", function () {
          const approvedAmount = amount;

          beforeEach(async function () {
            await token.approve(spender.address, approvedAmount, {
              from: initialHolder.address,
            });
          });

          it("decreases the spender allowance subtracting the requested amount", async function () {
            await token
              .connect(initialHolder)
              .decreaseAllowance(spender.address, approvedAmount.sub(1));

            expect(
              await token.allowance(initialHolder.address, spender.address)
            ).to.be.equal("1");
          });

          it("sets the allowance to zero when all allowance is removed", async function () {
            await token.decreaseAllowance(spender.address, approvedAmount, {
              from: initialHolder.address,
            });
            expect(
              await token.allowance(initialHolder.address, spender.address)
            ).to.be.equal("0");
          });

          it("reverts when more than the full allowance is removed", async function () {
            await expectRevert(
              token
                .connect(initialHolder)
                .decreaseAllowance(spender.address, approvedAmount.add(1)),
              "ERC20: decreased allowance below zero"
            );
          });
        });
      }

      describe("when the sender has enough balance", function () {
        const amount = initialSupply;

        shouldDecreaseApproval(amount);
      });

      describe("when the sender does not have enough balance", function () {
        const amount = initialSupply.add(1);

        shouldDecreaseApproval(amount);
      });
    });

    describe("when the spender is the zero address", async function () {
      const { token, initialHolder, initialSupply } = await loadFixture(
        deployTokenFixture
      );
      const amount = initialSupply;
      const spender = ZERO_ADDRESS;

      it("reverts", async function () {
        try {
          await expectRevert(
            token.connect(initialHolder).decreaseAllowance(spender, amount),
            "ERC20: approve to the zero address"
          );
        } catch (err) {
          console.error(err);
          console.error("hi");
        }
      });
    });
  });

  describe("increase allowance", async function () {
    const { initialSupply } = await loadFixture(deployTokenFixture);
    const amount = initialSupply;

    describe("when the spender is not the zero address", async function () {
      const {
        recipient: spender,
        token,
        initialHolder,
        initialSupply,
      } = await loadFixture(deployTokenFixture);

      describe("when the sender has enough balance", function () {
        describe("when there was no approved amount before", function () {
          it("approves the requested amount", async function () {
            await token.increaseAllowance(spender.address, amount, {
              from: initialHolder.address,
            });

            expect(
              await token.allowance(initialHolder.address, spender.address)
            ).to.be.equal(amount);
          });
        });

        describe("when the spender had an approved amount", function () {
          beforeEach(async function () {
            await token.approve(spender.address, ethers.BigNumber.from(1), {
              from: initialHolder.address,
            });
          });

          it("increases the spender allowance adding the requested amount", async function () {
            await token.increaseAllowance(spender.address, amount, {
              from: initialHolder.address,
            });

            expect(
              await token.allowance(initialHolder.address, spender.address)
            ).to.be.equal(amount.add(1));
          });
        });
      });

      describe("when the sender does not have enough balance", function () {
        const amount = initialSupply.add(1);

        describe("when there was no approved amount before", function () {
          it("approves the requested amount", async function () {
            await token.increaseAllowance(spender.address, amount, {
              from: initialHolder.address,
            });

            expect(
              await token.allowance(initialHolder.address, spender.address)
            ).to.be.equal(amount);
          });
        });

        describe("when the spender had an approved amount", function () {
          beforeEach(async function () {
            await token.approve(spender.address, ethers.BigNumber.from(1), {
              from: initialHolder.address,
            });
          });

          it("increases the spender allowance adding the requested amount", async function () {
            await token.increaseAllowance(spender.address, amount, {
              from: initialHolder.address,
            });

            expect(
              await token.allowance(initialHolder.address, spender.address)
            ).to.be.equal(amount.add(1));
          });
        });
      });
    });

    describe("when the spender is the zero address", async function () {
      const { token, initialHolder, initialSupply } = await loadFixture(
        deployTokenFixture
      );
      const spender = ZERO_ADDRESS;

      it("reverts", async function () {
        await expectRevert(
          token.increaseAllowance(spender, amount, {
            from: initialHolder.address,
          }),
          "ERC20: approve to the zero address"
        );
      });
    });
  });

  describe("_transfer", async function () {
    const context = await loadFixture(deployTokenFixture);

    shouldBehaveLikeERC20Transfer(
      "ERC20",
      context,
      context.initialHolder.address,
      context.recipient.address,
      context.initialSupply,
      (from: string, to: string, amount: BigNumber) => {
        return context.token.transfer(to, amount);
      }
    );

    describe("when the sender is the zero address", function () {
      it("reverts", async function () {
        await expectRevert(
          context.token.transferFrom(
            ZERO_ADDRESS,
            context.recipient.address,
            context.initialSupply
          ),
          "ERC20: transfer from the zero address"
        );
      });
    });
  });

  // describe("_approve", function () {
  //   shouldBehaveLikeERC20Approve(
  //     "ERC20",
  //     context,
  //     initialHolder,
  //     recipient,
  //     initialSupply,
  //     function (owner, spender, amount) {
  //       return token.approveInternal(owner.address, spender, amount);
  //     }
  //   );

  //   describe("when the owner is the zero address", function () {
  //     it("reverts", async function () {
  //       await expectRevert(
  //         token.approveInternal(ZERO_ADDRESS, recipient, initialSupply),
  //         "ERC20: approve from the zero address"
  //       );
  //     });

  //     it("End of Testing", function () {});
  //   });
  // });
  describe("ERC5827", async function () {
    const context = await loadFixture(deployTokenFixture);

    shouldBehaveLikeERC5827(
      "ERC20",
      context,
      context.initialSupply,
      context.initialHolder,
      context.recipient,
      context.anotherAccount
    );
  });
});
