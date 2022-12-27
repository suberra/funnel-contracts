// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import {FundLossRecipe} from "pnm-contracts/recipes/FundLossRecipe.sol";

contract FundLossTest is FundLossRecipe {
    // MyContract myContract;

    // Define how to deploy the contract(s) to be tested
    // Returns the one for balance checking
    function deploy() public override returns (address) {
        // TODO: Implemement this
        // e.g.
        // myContract = new MyContract("ETH");
        // return address(myContract);
        return address(0);
    }

    // Define how to calculate the vaule you want to check
    function getTargetBalance(address target)
        public
        override
        returns (uint256)
    {
        // TODO: Implemement this
        // e.g.
        // return address(myContract).balance + myContract.getAllTokenBalanceInEth();
        return 0;
    }

    // TODO: To customize report trigerring condition, you could override following functions:
    // function checkProtocolFundIsSafe(address protocol, uint256 initValue) public override {}
    // function checkUserFundIsSafe(address user, uint256 initValue) public override {}
    // function checkAgentFundNoGain(address agent, uint256 initValue) public override {}
}
