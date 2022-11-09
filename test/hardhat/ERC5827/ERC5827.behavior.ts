const { expectRevert } = require('@openzeppelin/test-helpers')

import { ethers, network } from 'hardhat'
import { expect } from 'chai'

const ZERO_ADDRESS = ethers.constants.AddressZero
const MAX_UINT256 = ethers.constants.MaxUint256

export function shouldBehaveLikeERC5827(errorPrefix, context, initialSupply, initialHolder, recipient, anotherAccount) {
  describe('ERC5827.supportsInterface', function () {
    it('supportsInterface should return true', async function () {
      expect(await context.token.supportsInterface(0xc55dae63)).to.be.equal(true)
    })

    it('supportsInterface should return false', async function () {
      expect(await context.token.supportsInterface(0xc55dae64)).to.be.equal(false)
    })
  })

  describe('ERC5827.baseToken', function () {
    it('baseToken should return ERC20 address', async function () {
      expect(await context.token.baseToken()).to.be.equal(context.token20.address)
    })
  })

  describe('ERC5827.approveRenewable', function () {
    const approveAmount = ethers.BigNumber.from('10')
    const recoverAmount = ethers.BigNumber.from('1')
    const transferAmount = ethers.BigNumber.from('7')
    const remainAmount = approveAmount.sub(transferAmount)

    let timestamp

    async function getLatestTimeStamp() {
      const blockNumber = await ethers.provider.getBlockNumber()
      return (await ethers.provider.getBlock(blockNumber)).timestamp
    }

    async function getTimeDiff() {
      return (await getLatestTimeStamp()) - timestamp
    }

    beforeEach(async function () {
      await context.token.approveRenewable(recipient, approveAmount, recoverAmount)
      await context.token.connect(context.recipient).transferFrom(initialHolder, recipient, transferAmount)
      timestamp = await getLatestTimeStamp()
    })

    describe('when recoveryRate exceeds amount', function () {
      it('reverts', async function () {
        await expectRevert(
          context.token.approveRenewable(recipient, approveAmount, approveAmount.add(1)),
          'ERC5827: recoveryRate cannot be greater than approved amount',
        )
      })
    })

    describe('when allowance is not overflow', function () {
      it('allowance should be correct', async function () {
        try {
          expect(await context.token.allowance(initialHolder, recipient)).to.be.equal(
            remainAmount.add(ethers.BigNumber.from(await getTimeDiff())),
          )

          await network.provider.send('evm_increaseTime', [4])
          await network.provider.send('evm_mine')

          expect(await context.token.allowance(initialHolder, recipient)).to.be.equal(
            remainAmount.add(ethers.BigNumber.from(await getTimeDiff())),
          )
        } catch (err) {
          console.error(err)
        }
      })
    })

    describe('when allowance is overflow', function () {
      it('allowance should be correct', async function () {
        try {
          expect(await context.token.allowance(initialHolder, recipient)).to.be.equal(
            approveAmount.sub(transferAmount).add(ethers.BigNumber.from((await getLatestTimeStamp()) - timestamp)),
          )

          await network.provider.send('evm_increaseTime', [200])
          await network.provider.send('evm_mine')

          expect(await context.token.allowance(initialHolder, recipient)).to.be.equal(approveAmount)
        } catch (err) {
          console.error(err)
        }
      })
    })

    describe('when the approve is not ready', function () {
      it('emits a set renewable allowance event', async function () {
        await expect(context.token.approveRenewable(recipient, approveAmount, recoverAmount))
          .to.emit(context.token, 'RenewableApproval')
          .withArgs(initialHolder, recipient, approveAmount, recoverAmount)
      })

      it('reverts', async function () {
        await ethers.provider.send('evm_increaseTime', [2])
        await ethers.provider.send('evm_mine', [0])

        await expectRevert(
          context.token.connect(context.recipient).transferFrom(initialHolder, recipient, approveAmount),
          `InsufficientRenewableAllowance`,
          remainAmount.add(ethers.BigNumber.from(await getTimeDiff())),
        )
      })
    })

    describe('when the approve is ready', function () {
      it('recovers allowance', async function () {
        try {
          await ethers.provider.send('evm_increaseTime', [7])
          await ethers.provider.send('evm_mine', [])

          await context.token.connect(context.recipient).transferFrom(initialHolder, recipient, approveAmount)
        } catch (err) {
          console.error('error', err)
        }
      })

      it('End of Testing', async function () {})
    })
  })
}
