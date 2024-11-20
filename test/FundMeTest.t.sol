// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Test, console} from "forge-std/Test.sol"; // import the test and console package from foundry. the test package is for testing. the console package is for console.logging
import {FundMe} from "../src/FundMe.sol";

contract FundMeTest is Test {
    // to test functions in the FundMe contract, we need to declare the fundMe variable of type FundMe contract at the contract level and initialize it in the setup function. (This makes the variable a storage or state variable )
    FundMe fundMe;
    // ^ we declare this at the contract level so it can be in scope to all functions in this contract ^

    // every test contract needs to have a setup function. in this setup function, we deploy the contract that we are testing.
    // when we run `forge test`, the setup function always get called before any test function
    function setUp() external {
        // the fundMe variable of type FundMe contract is gonna be a new FundMe contract. The constructor takes no input parameters so we don't pass any parameters.
        fundMe = new FundMe();
        // ^ we deploy a new contract in a testing environment to test the contract ^
    }

    // testing to make sure that the minimum deposit is indeed $5
    function testMinimumDollarisFive() public {
        // assertEq is from the test foundry package
        // this line says that we are assert that the minimum USD variable in the fundMe contract is equal to 5e18.
        assertEq(fundMe.MINIMUM_USD(), 5e18); // the test passes. if you change it to 6e18 then the test fails.
    }

    function testOwnerIsMsgSender() public {
        // console.log(fundMe.i_owner());
        // console.log(msg.sender);
        // this line fails. we can console.log above it to find out why.
        // assertEq(fundMe.i_owner(), msg.sender);
        // ^this line fails because in the setup function, this contract of `FundMeTest` is the one that deployed the FundMe Contract and so the FundMeTest is the owner.

        // so the correct line is:
        assertEq(fundMe.i_owner(), address(this));
        // this line passes because it is asserting that the owner of the FundMe contract is indeed the owner of the deployed contract as the constructor is FundMe says it should be.
    }
}
