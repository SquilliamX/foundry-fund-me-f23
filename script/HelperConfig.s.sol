// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

/* this contract will do the following:
1. Deploy mocks when we are on a local Anvil Chain
2. Keep track of contract addresses across different chains
*/

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    // If we are on a local anvil, we deploy mocks.
    // Otherwise, grab the existing address from the live network.

    // we are declaring a variable named activeNetworkConfig of type struct NetworkConfig to use
    NetworkConfig public activeNetworkConfig;

    // to reduce magic numbers we defined these. these are the decimal count and start price of ETH/USD in the mockV3Aggregator.
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    // the items inside the FundMe.sol constructor
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
            // if the chain is not 11155111, then use `getAnvilEthConfig()` (the getAnvilEthConfig function uses a mock to simulate the pricefeed since its a fake temporary empty blockchain and does not have chainlink pricefeeds)
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        // we want to get the price feed address.
        // but what if we want more than just one variable? We create a struct (so we made struct NetworkConfig)!

        // this grabs the pricefeed address that we hardcoded and saves it to a variable named sepoliaConfig
        NetworkConfig memory sepoliaConfig = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        // returns the variable sepoliaConfig when this function is called.
        return sepoliaConfig; //  This returns the pricefeed address saved in the variable gets passed to the deployment script to let it know what the address it to pull data from the address.
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        // we want to get the price feed address.
        // but what if we want more than just one variable? We create a struct (so we made struct NetworkConfig)!

        // this grabs the pricefeed address that we hardcoded and saves it to a variable named sepoliaConfig
        NetworkConfig memory ethConfig = NetworkConfig({priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
        // returns the variable sepoliaConfig when this function is called.
        return ethConfig; //  This returns the pricefeed address saved in the variable gets passed to the deployment script to let it know what the address it to pull data from the address.
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        // we want to get the price feed address, but this is anvils local blockchain, that does not have pricefeeds.
        // so we need to deploy mocks onto the local blockchain(anvil) to simulate pricefeeds.

        // 1. Deploy Mocks
        // 2. Return the Mock addresses

        // this if statement is saying that if we already have deployed a mockV3Aggregator, to use that one instead of deploying a new one everytime.
        // if it is not address 0 then this means we already deployed it and it has an address, otherwise it would be 0 if it didnt exist.
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        } // we do not need an "else" clause here because once a return statement in a function is executed, the function immediately exits and no further code in that function will run.

        // everything inbetween the startBroadcast is being broadcasted to the blockchain. So here we are deploying the mock to anvil.
        vm.startBroadcast();
        // this says to deploy a new MockV3Aggregator and save it in a variable of MockV3Aggregator named mockPriceFeed.
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        // ^ we passed `8` and `2000e8` as parameters because the MockV3Aggregator's constructor asks for decimals and inital price. So here we are saying that the pair price feed that we are mocking(eth/usd) has 8 decimals and the starting price is 2000 with 8 decimals(2000e8). ^
        vm.stopBroadcast();

        // grabs the address of the mock pricefeed (within the struct we declared) and saves it as variable of type struct NetworkConfig named anvilConfig
        NetworkConfig memory anvilConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});
        // returns this variable anvilConfig when this function is called. This returns the pricefeed address saved in the variable gets passed to the deployment script to let it know what the address it to pull data from the address.
        return anvilConfig;
    }
}
