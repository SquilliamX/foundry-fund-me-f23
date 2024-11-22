// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Test, console} from "forge-std/Test.sol"; // import the test and console package from foundry. the test package is for testing. the console package is for console.logging
import {FundMe} from "../../src/FundMe.sol";
import {PriceConverter} from "../../src/PriceConverter.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";

contract FundMeIntegration is Test {
    // to test functions in the FundMe contract, we need to declare the fundMe variable of type FundMe contract at the contract level and initialize it in the setup function. (This makes the variable a storage or state variable )
    FundMe fundMe;
    // ^ we declare this at the contract level so it can be in scope to all functions in this contract ^

    // creating a user so that he can send the transactions in our tests. "MakeAddr" is a cheatcode from foundry that allows use to make a fake address for someone for testing purposes(we named the address being made "user" and the person is called USER).
    address USER = makeAddr("user");

    // the amount we are sending in tests
    uint256 constant SEND_VALUE = 0.1 ether;

    // this is the amount that we are going to pass to the "USER" saved as a variable to avoid magic numbers.
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() public {
        // we deploy the script that deploys the FundMe contract and save it as a variable named deployFundMe
        DeployFundMe deployFundMe = new DeployFundMe();
        // since the run function returns the fundMe contract and we save it as a variable named fundMe.
        fundMe = deployFundMe.run();
        // we need to give the fake person "USER" some money so he has money in his wallet to make transactions with. This needs to go in the setup function because the setup function is always called before the tests when we run `forge test`
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundAndOwnerWithdraw() public {
        // gets the USER balance before the USER funds the contract
        uint256 preUserBalance = address(USER).balance;
        // gets the owners balance before he withdraws funds
        uint256 preOwnerBalance = address(fundMe.getOwner()).balance;

        // Using vm.prank to simulate funding from the USER address
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}(); // USER sends money

        // deploys a new WithdrawFundMe interactions contract and saves it in a variable of type WithdrawFundMe named withdrawFundMe
        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        // calls the variable we just made and calls the withdrawFundMe function inside the interactions contract to withdraw the funds as we are the owner.
        withdrawFundMe.withdrawFundMe(address(fundMe));

        // takes the balance of the user after he funded the contract
        uint256 afterUserBalance = address(USER).balance;
        // gets the balance of the owner after he withdrew
        uint256 afterOwnerBalance = address(fundMe.getOwner()).balance;

        // asserts that the fundMe contract balance is 0 since we withdrew all the funds
        assert(address(fundMe).balance == 0);
        // asserts that the Users balance after he sent funds and plus the amount he sent is equal to how much is had before he sent
        assertEq(afterUserBalance + SEND_VALUE, preUserBalance);
        // asserts that the owners balance before he withdrew plus the value sent from the user is equal to the amount the owner has after he withdrew.
        assertEq(preOwnerBalance + SEND_VALUE, afterOwnerBalance);
    }
}
