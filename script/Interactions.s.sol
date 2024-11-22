// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import {Script, console} from "forge-std/Script.sol";

// this import is a tool to grab the most recently deployed contract address
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
// ^ this package help your foundry keep track of your most recently deployed version of a contract. ^

import {FundMe} from "../src/FundMe.sol";

// this is going to be our script for funding the fundMe contract
contract FundFundMe is Script {
    // amount we are funding with
    uint256 constant SEND_VALUE = 0.01 ether;

    function fundFundMe(address mostRecentlyDeplyed) public {
        // takes an input parameter of an address, which is going to be the mostRecentlyDeplyed address of our contract and funds it with the amount we want.
        FundMe(payable(mostRecentlyDeplyed)).fund{value: SEND_VALUE}();

        console.log("Funded FundMe with %s", SEND_VALUE); // import the console.log from the script directory
            // this console.log also lets us know when the transaction goes through because it pops up when the transaction goes through.
    }

    function run() external {
        // grabs the most recent deployment from the broadcast folder. takes the name of the contract and the blockchain so it knows what to do
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        // calls the fundFundMe function to deploy funds to the most recently deployed contract
        // `startBroadcast` sends all transactions between startBroadcast and stopBroadcast
        vm.startBroadcast();
        fundFundMe(mostRecentlyDeployed);
        vm.stopBroadcast();
    }
}

// this is going to be our script for withdrawing from the fundMe contract
contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentlyDeplyed) public {
        vm.startBroadcast();
        // takes an input parameter of an address, which is going to be the mostRecentlyDeplyed address of our contract and funds it with the amount we want.
        FundMe(payable(mostRecentlyDeplyed)).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        // grabs the most recent deployment from the broadcast folder. takes the name of the contract and the blockchain so it knows what to do
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        // calls the fundFundMe function to deploy funds to the most recently deployed contract
        // `startBroadcast` sends all transactions between startBroadcast and stopBroadcast
        withdrawFundMe(mostRecentlyDeployed);
    }
}
