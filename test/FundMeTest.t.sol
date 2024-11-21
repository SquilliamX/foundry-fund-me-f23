// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Test, console} from "forge-std/Test.sol"; // import the test and console package from foundry. the test package is for testing. the console package is for console.logging
import {FundMe} from "../src/FundMe.sol";
import {PriceConverter} from "../src/PriceConverter.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    // to test functions in the FundMe contract, we need to declare the fundMe variable of type FundMe contract at the contract level and initialize it in the setup function. (This makes the variable a storage or state variable )
    FundMe fundMe;
    // ^ we declare this at the contract level so it can be in scope to all functions in this contract ^

    // creating a user so that he can send the transactions in our tests. "MakeAddr" is a cheatcode from foundry that allows use to make a fake address for someone for testing purposes(we named the address being made "user" and the person is called USER).
    address USER = makeAddr("user");

    // the amount we are sending in tests
    uint256 constant SEND_VALUE = 0.1 ether;

    // this is the amount that we are going to pass to the "USER" saved as a variable to avoid magic numbers.
    uint256 constant STARTING_BALANCE = 10 ether;

    // every test contract needs to have a setup function. in this setup function, we deploy the contract that we are testing.
    // when we run `forge test`, the setup function always get called before any test function
    function setUp() external {
        // the fundMe variable of type FundMe contract is gonna be a new FundMe contract. The constructor takes no input parameters so we don't pass any parameters.
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306); // doing it like this will mean everytime we change our blockchain we also have to change our test. instead we can do it like (below):
        // ^ we deploy a new contract in a testing environment to test the contract ^

        // we deploy the script that deploys the FundMe contract and save it as a variable named deployFundMe
        DeployFundMe deployFundMe = new DeployFundMe();
        // since the run function returns the fundMe contract and we save it as a variable named fundMe.
        fundMe = deployFundMe.run();
        // we need to give the fake person "USER" some money so he has money in his wallet to make transactions with. This needs to go in the setup function because the setup function is always called before the tests when we run `forge test`
        vm.deal(USER, STARTING_BALANCE);
    }

    // testing to make sure that the minimum deposit is indeed $5
    function testMinimumDollarisFive() public {
        // assertEq is from the test foundry package
        // this line says that we are assert that the minimum USD variable in the fundMe contract is equal to 5e18.
        assertEq(fundMe.MINIMUM_USD(), 5e18); // the test passes. if you change it to 6e18 then the test fails.
    }

    // testing constructor logic
    function testOwnerIsMsgSender() public {
        // console.log(fundMe.i_owner());
        // console.log(msg.sender);
        // this line fails. we can console.log above it to find out why.
        // assertEq(fundMe.i_owner(), msg.sender);
        // ^this line fails because in the setup function, this contract of `FundMeTest` is the one that deployed the FundMe Contract and so the FundMeTest is the owner.

        // so the correct line is:
        // assertEq(fundMe.i_owner(), address(this)); now that we refactor this can be msg.sender again.
        // this line passes because it is asserting that the owner of the FundMe contract is indeed the owner of the deployed contract as the constructor is FundMe says it should be.
        assertEq(fundMe.i_owner(), msg.sender); // this is back to msg.sender because we use "vm.startBroadcast" in our deployment script. // From my understanding it is because before we were deploying FundMe ourselves to test here, but now that we are calling the deployment script to launch the fundMe contract(using `vm.startBroadcast`), everything is set to normal and the script is NOT the owner, we are, as we broadcasted/deployed it and used the script.
    }

    // testing PriceFeed logic integration from chainlink
    function testPriceFeedVersionIsAccurate() public {
        // this is how you write the test:
        // if the chainid is 11155111, then run the get verison functionn and assert it equals 4
        if (block.chainid == 11155111) {
            uint256 version = fundMe.getVersion();
            assertEq(version, 4);
            // if the chainid is 1, then run the get verison functionn and assert it equals 6
        } else if (block.chainid == 1) {
            uint256 version = fundMe.getVersion();
            assertEq(version, 6);
        }

        // uint256 version = fundMe.getVersion();
        // assertEq(version, 4);
        // this two line test above fails! it fails because since we did not identify a chain, anvil spins up a chain, but the contract address does not exist on anvil!
    }

    // this test is making sure that if a user sends less than the minimum amount, the contract will revert and not allow it.
    function testFundFailsWithoutEnoughEth() public {
        // this is a cheat code in foundry. it is telling foundry that the next line should revert.
        vm.expectRevert();

        fundMe.fund(); // send zero value. this fails because there is a minimum that needs to be sent.
            // so because we used expectRevert, this test passes.
    }

    // this test is testing to make sure that all the logic in the fund function works. This includes the keeping track of the mapping and pushing the user into the array.
    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); // the next transaction will be sent by "USER".
        fundMe.fund{value: SEND_VALUE}(); // so this value is sent by the "USER"
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }
}
