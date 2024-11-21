// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

// we must import Script.sol to tell foundry that this is a script.
import {Script} from "forge-std/Script.sol"; // we need to import the script package from foundry when working on scripts in foundry/solidity.
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

// this script will deploy our smart contracts. we should always deploy smart contracts this way.
// Script contracts always need to inherit from scripts
contract DeployFundMe is Script {
    // all deployments scripts need to have this "run" function because this will be the main function called when deploying the contract.
    function run() external returns (FundMe) {
        // this says that when we start this `run` function, it will create a new helperconfig of type HelperConfig contract.
        HelperConfig helperConfig = new HelperConfig();
        // because we send this before `vm.startBroadcast`, it is executing this code in a simulated environment. So it is grabbing the chainId that we are deploying to right before we deploy the contracts

        // we get the activeNetwork's pricefeed address and save it as a variable called "ethUsdPriceFeed"
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();
        // `activeNetworkConfig` is a variable of type struct, so if we had more variables in the struct, depending on what we would want we should save it as (address ethUsdPriceFeed, address exampleAddress, , ,)

        // "vm.startBroadcast" is a cheatcode from foundry. it tells foundry "everything after this line should be sent to the rpc"
        vm.startBroadcast();
        // this line says variable name "fundMe" of type contract FundMe is equal to a new FundMe contract that is now being created and the broadcast line deploys it.
        // FundMe fundMe = new FundMe(); // this line throws a warning since we do not use the variable fundMe
        // new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306); // this also creates a new FundMe contract

        // we use this because now it will be more modular. All we do is now change this address and it will update our entire codebase.
        FundMe fundMe = new FundMe(ethUsdPriceFeed); // this address gets inputted into the FundMe constructor.
        vm.stopBroadcast();
        return fundMe; // because this returns the deployed fundMe contract, we can make changes and it will always return the change we made. making the testing easier and more modular.
    }
}
