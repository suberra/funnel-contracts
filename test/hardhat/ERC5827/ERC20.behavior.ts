import { BigNumber, Contract } from "ethers";
import { ethers } from "hardhat";
import { expect } from "chai";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { IERC20 } from "../../../typechain-types";

const ZERO_ADDRESS = ethers.constants.AddressZero;
const MAX_UINT256 = ethers.constants.MaxUint256;

function expectRevert(promise: Promise<any>, expectedError: string) {
  return expect(promise).to.be.revertedWith(expectedError);
}
export interface IERC20BehaviourContext {
  token: IERC20;
  initialHolder: SignerWithAddress;
  recipient: SignerWithAddress;
  anotherAccount: SignerWithAddress;
}

export function shouldBehaveLikeERC20(
  errorPrefix: string,
  context: IERC20BehaviourContext,
  initialSupply: BigNumber,
  initialHolder: string,
  recipient: string,
  anotherAccount: string
) {
  describe("total supply", function () {
    it("returns the total amount of tokens", async function () {
      expect(await context.token.totalSupply()).to.be.equal(initialSupply);
    });
  });

  describe("balanceOf", function () {
    describe("when the requested account has no tokens", function () {
      it("returns zero", async function () {
        expect(await context.token.balanceOf(anotherAccount)).to.be.equal("0");
      });
    });

    describe("when the requested account has some tokens", function () {
      it("returns the total amount of tokens", async function () {
        expect(await context.token.balanceOf(initialHolder)).to.be.equal(
          initialSupply
        );
      });
    });
  });

  describe("transfer", function () {
    shouldBehaveLikeERC20Transfer(
      errorPrefix,
      context,
      initialHolder,
      recipient,
      initialSupply,
      function (from: string, to: string, value: BigNumber) {
        return context.token.transfer(to, value, { from });
      }
    );
  });

  describe("transfer from", function () {
    const spender = context.recipient;

    describe("when the token owner is not the zero address", function () {
      const tokenOwner = initialHolder;

      describe("when the recipient is not the zero address", function () {
        const to = anotherAccount;

        describe("when the spender has enough allowance", function () {
          beforeEach(async function () {
            await context.token
              .connect(context.initialHolder)
              .approve(spender.address, initialSupply);
          });

          describe("when the token owner has enough balance", function () {
            const amount = initialSupply;

            it("transfers the requested amount", async function () {
              try {
                await context.token
                  .connect(spender)
                  .transferFrom(tokenOwner, to, amount);

                expect(await context.token.balanceOf(tokenOwner)).to.be.equal(
                  "0"
                );

                expect(await context.token.balanceOf(to)).to.be.equal(amount);
              } catch (err) {
                console.error(err);
              }
            });

            it("decreases the spender allowance", async function () {
              try {
                await context.token
                  .connect(spender)
                  .transferFrom(tokenOwner, to, amount);

                expect(
                  await context.token.allowance(tokenOwner, spender.address)
                ).to.be.equal("0");
              } catch (err) {
                console.error(err);
              }
            });

            it("emits a transfer event", async function () {
              await expect(
                context.token
                  .connect(spender)
                  .transferFrom(tokenOwner, to, amount)
              )
                .to.not.emit(context.token, "Transfer")
                .withArgs(tokenOwner, to, amount);
            });
          });

          describe("when the token owner does not have enough balance", function () {
            const amount = initialSupply;

            beforeEach("reducing balance", async function () {
              await context.token
                .connect(context.initialHolder)
                .transfer(to, 1);
            });

            it("reverts", async function () {
              await expectRevert(
                context.token
                  .connect(spender)
                  .transferFrom(tokenOwner, to, amount),
                `${errorPrefix}: transfer amount exceeds balance`
              );
            });
          });
        });

        describe("when the spender does not have enough allowance", function () {
          const allowance = initialSupply.sub(1);

          beforeEach(async function () {
            await context.token
              .connect(context.initialHolder)
              .approve(spender.address, allowance);
          });

          describe("when the token owner has enough balance", function () {
            const amount = initialSupply;

            it("reverts", async function () {
              await expect(
                context.token
                  .connect(spender)
                  .transferFrom(tokenOwner, to, amount)
              ).to.be.reverted;
            });
          });

          describe("when the token owner does not have enough balance", function () {
            const amount = allowance;

            beforeEach("reducing balance", async function () {
              await context.token
                .connect(context.initialHolder)
                .transfer(to, 2);
            });

            it("reverts", async function () {
              await expectRevert(
                context.token
                  .connect(spender)
                  .transferFrom(tokenOwner, to, amount),
                `${errorPrefix}: transfer amount exceeds balance`
              );
            });
          });
        });

        describe("when the spender has unlimited allowance", function () {
          beforeEach(async function () {
            await context.token
              .connect(context.initialHolder)
              .approve(spender.address, MAX_UINT256);
          });

          it("does not decrease the spender allowance", async function () {
            await context.token
              .connect(spender)
              .transferFrom(tokenOwner, to, 1);

            expect(
              await context.token.allowance(tokenOwner, spender.address)
            ).to.be.equal(MAX_UINT256);
          });
        });
      });

      describe("when the recipient is the zero address", function () {
        const amount = initialSupply;
        const to = ZERO_ADDRESS;

        beforeEach(async function () {
          await context.token
            .connect(context.initialHolder)
            .approve(spender.address, amount);
        });

        it("reverts", async function () {
          await expectRevert(
            context.token.connect(spender).transferFrom(tokenOwner, to, amount),
            `${errorPrefix}: transfer to the zero address`
          );
        });
      });
    });

    describe("when the token owner is the zero address", function () {
      const amount = 0;
      const tokenOwner = ZERO_ADDRESS;
      const to = recipient;

      it("reverts", async function () {
        await expectRevert(
          context.token.connect(spender).transferFrom(tokenOwner, to, amount),
          "from the zero address"
        );
      });
    });
  });

  describe("approve", function () {
    shouldBehaveLikeERC20Approve(
      errorPrefix,
      context,
      context.initialHolder,
      recipient,
      initialSupply,
      function (owner, spender, amount) {
        return context.token.connect(owner).approve(spender, amount);
      }
    );
  });
}

export function shouldBehaveLikeERC20Transfer(
  errorPrefix,
  context,
  from,
  to,
  balance,
  transfer
) {
  describe("when the recipient is not the zero address", function () {
    describe("when the sender does not have enough balance", function () {
      const amount = balance.add(1);

      it("reverts", async function () {
        await expectRevert(
          transfer.call(this, from, to, amount),
          `${errorPrefix}: transfer amount exceeds balance`
        );
      });
    });

    describe("when the sender transfers all balance", function () {
      const amount = balance;

      it("transfers the requested amount", async function () {
        try {
          await transfer.call(this, from, to, amount);

          expect(await context.token.balanceOf(from)).to.be.equal("0");

          expect(await context.token.balanceOf(to)).to.be.equal(amount);
        } catch (err) {
          console.error(err);
        }
      });
    });

    describe("when the sender transfers zero tokens", function () {
      const amount = ethers.BigNumber.from("0");

      it("transfers the requested amount", async function () {
        await transfer.call(this, from, to, amount);

        expect(await context.token.balanceOf(from)).to.be.equal(balance);

        expect(await context.token.balanceOf(to)).to.be.equal("0");
      });
    });
  });

  describe("when the recipient is the zero address", function () {
    it("reverts", async function () {
      await expectRevert(
        transfer.call(this, from, ZERO_ADDRESS, balance),
        `${errorPrefix}: transfer to the zero address`
      );
    });
  });
}

export function shouldBehaveLikeERC20Approve(
  errorPrefix,
  context,
  owner,
  spender,
  supply,
  approve
) {
  describe("when the spender is not the zero address", function () {
    describe("when the sender has enough balance", function () {
      const amount = supply;

      describe("when there was no approved amount before", function () {
        it("approves the requested amount", async function () {
          try {
            await approve.call(this, owner, spender, amount);
            expect(
              await context.token.allowance(owner.address, spender)
            ).to.be.equal(amount);
          } catch (err) {
            console.error(err);
          }
        });
      });

      describe("when the spender had an approved amount", function () {
        beforeEach(async function () {
          await approve.call(this, owner, spender, ethers.BigNumber.from(1));
        });

        it("approves the requested amount and replaces the previous one", async function () {
          await approve.call(this, owner, spender, amount);

          expect(
            await context.token.allowance(owner.address, spender)
          ).to.be.equal(amount);
        });
      });
    });

    describe("when the sender does not have enough balance", function () {
      const amount = supply.add(1);

      it("emits an approval event", async function () {
        await expect(approve.call(this, owner, spender, amount))
          .to.emit(context.token, "RenewableApproval")
          .withArgs(owner.address, spender, amount, 0);
      });

      describe("when there was no approved amount before", function () {
        it("approves the requested amount", async function () {
          await approve.call(this, owner, spender, amount);

          expect(
            await context.token.allowance(owner.address, spender)
          ).to.be.equal(amount);
        });
      });

      describe("when the spender had an approved amount", function () {
        beforeEach(async function () {
          await approve.call(this, owner, spender, ethers.BigNumber.from(1));
        });

        it("approves the requested amount and replaces the previous one", async function () {
          await approve.call(this, owner, spender, amount);

          expect(
            await context.token.allowance(owner.address, spender)
          ).to.be.equal(amount);
        });
      });
    });
  });

  describe("when the spender is the zero address", function () {
    it("reverts", async function () {
      await expectRevert(
        approve.call(this, owner, ZERO_ADDRESS, supply),
        `${errorPrefix}: approve to the zero address`
      );
    });
  });
}
