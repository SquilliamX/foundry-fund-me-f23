// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

/* this contract will do the following:
1. Deploy mocks when we are on a local Anvil Chain
2. Keep track of contract addresses across different chains
*/

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";

contract HelperConfig is Script {
    // If we are on a local anvil, we deploy mocks.
    // Otherwise, grab the existing address from the live network.

    // we are declaring a variable named activeNetworkConfig to use
    NetworkConfig public activeNetworkConfig;

    struct NetworkConfig {
        address priceFeed; // ETH/USD pricefeed address
    }

    constructor() {
        // every blockchain has a chainId. The `block.chainid` is a key word from solidity.
        // this is saying "if we the chain we are on has a chainId of 11155111, then use `getSepoliaEthConfig()` (this getSepoliaEthConfig function returns the pricefeed address to use)"
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            // this is saying "if we the chain we are on has a chainId of 1, then use `getMainnetEthConfig()` (this getMainnetEthConfig function returns the pricefeed address to use)"
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            // if the chain is not 11155111, then use `getAnvilEthConfig()` (the getAnvilEthConfig function uses a mock to simulate the pricefeed since its a fake temporary blockchain)
            activeNetworkConfig = getAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        // we want to get the price feed address.
        // but what if we want more than just one variable? We create a struct (so we made struct NetworkConfig)!

        // this grabs the pricefeed address that we hardcoded and saves it to a variable named sepoliaConfig
        NetworkConfig memory sepoliaConfig = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        // returns the variable sepoliaConfig when this function is called.
        return sepoliaConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        // we want to get the price feed address.
        // but what if we want more than just one variable? We create a struct (so we made struct NetworkConfig)!

        // this grabs the pricefeed address that we hardcoded and saves it to a variable named sepoliaConfig
        NetworkConfig memory ethConfig = NetworkConfig({priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
        // returns the variable sepoliaConfig when this function is called.
        return ethConfig;
    }

    function getAnvilEthConfig() public pure returns (NetworkConfig memory) {
        // we want to get the price feed address
    }
}
