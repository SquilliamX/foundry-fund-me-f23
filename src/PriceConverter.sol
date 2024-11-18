// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    // libraries cannot have any state variables. State Variables are variables declared on the contract level.
    //  this function will get the price of the naive blockchain token(in this case its eth) in terms of USD
    function getPrice() internal view returns (uint256) {
        // to reach out to this contract, we need the Address and the ABI
        // address: 0x694AA1769357215DE4FAC081bf1f309aDC325306 ✅ (This is the address of the ETH/USD datafeed from chainlink)
        // ABI: Chainlink's AggregatorV3Interface ✅(the interface acts like an ABI). when we combine a contracr address with the interface, we can easily call the functions in that contract
        // the formating of this code comes from the docs of chainlink which can be found at https://docs.chain.link/data-feeds/using-data-feeds
        AggregatorV3Interface dataFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        // the formating of this code comes from the docs of chainlink which can be found at https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol
        (, int256 answer,,,) = dataFeed.latestRoundData();
        // ^ because we dont need the other items, we can just remove them and keep the commas.
        // this will return the price of ETH in terms of USD
        // so if the value is $3k, it will show as 300000000000 (8decimals).
        return uint256(answer * 1e10);
        // ^ we multiply this by 1e10 to get 18 decimals instead of 8!
        // ^^ we typecast this with uint256 because the answer returned is in int and we need it in uint. This is because int can be negative and this can lead to bugs. Uint can never be negative. Also, we typecasted because our msg.value is type uint and answer is type int, so we need to convert it.
        // to typecast means we did that uint256() around the answer * 1e10 to convert it to a different type.
    }

    // this function will convert the msg.value price(in the fund function) of eth into USD
    function getConversionRate(uint256 ethAmount) internal view returns (uint256) {
        uint256 ethPrice = getPrice();
        // we divide this by 1e18 because both eth price and ethAmount have 18 zeros, so the outcome would be 36 zeros if we dont divide.
        // you always want to multiply before you divide.
        // the user inputs in ethAmount
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUsd;
    }

    // this works because the address defined is correlated the functions "AggregatorV3Interface" and "version". We also imported the "AggregatorV3Interface" from chainlink.
    function getVersion() internal view returns (uint256) {
        return AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306).version();
    }

    function getDecimals() internal view returns (uint8) {
        return AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306).decimals();
    }
}
