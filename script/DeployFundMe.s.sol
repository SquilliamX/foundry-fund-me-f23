// SPDX-License-Identifier: MIT

pragma solidity 0.8.18;

// we must import Script.sol to tell foundry that this is a script.
import {Script} from "forge-std/Script.sol"; // we need to import the script package from foundry when working on scripts in foundry/solidity.
import {FundMe} from "../src/FundMe.sol";

// this script will deploy our smart contracts. we should always deploy smart contracts this way.
contract DeployFundMe is
    Script // Script contracts always need to inherit from scripts
{
    // all deployments scripts need to have this "run" function because this will be the main function called when deploying the contract.
    function run() external {
        // "vm.startBroadcast" is a cheatcode from foundry. it tells foundry "everything after this line should be sent to the rpc"
        vm.startBroadcast();
        // this line says variable name "fundMe" of type contract FundMe is equal to a new FundMe contract that is now being created and the broadcast line deploys it.
        // FundMe fundMe = new FundMe(); // this line throws a warning since we do not use the variable fundMe
        new FundMe(); // this also creates a new FundMe contract
        vm.stopBroadcast();
    }
}
