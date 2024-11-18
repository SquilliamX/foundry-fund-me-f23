// when starting a new project, write down what you want the code to do

// get funds from users
// withdraw funds
// set a minimum funding value is USD

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";

error NotOwner();

contract FundMe {
    // to attach the Price Converter functions to all uint256s:
    using PriceConverter for uint256;

    // uint256 public minimumUsd = 5 * (10 ** 18); // you can do this
    uint256 public constant MINIMUM_USD = 5e18; // this is the same as above. We do this because solidity needs to know to keep it in terms of eth.
    // this is marked with "constant" to save gas. Now when this contract is deployed, this variable will be stored into the bytecode instead of a storage slot. ** Only use constant on variables that will never change and these cannot be changed later on. **
    // constant variables should be capitalized and use underscores

    // an array of addresses called funders.
    address[] public funders;

    // a mapping, mapping the addresses and their amount funded.
    // the names "funder" and "amountFunded" is "syntaxic sugar", just makes it easier to read
    mapping(address funder => uint256 amountFunded) public addressToAmountFunded;

    // to be used in constructor
    address public immutable i_owner; // variables defined in seperate lines than where they are defined, can be marked as immutable if they will not change. This will save gas
    // immutable varibles should use "i_" in their name

    // the constructor is a function that gets immediately called when the contract is deployed.
    constructor() {
        // makes the deployer of this contract the "owner" of this contract.
        i_owner = msg.sender;
    }

    // the "payable" keyword is allows functions to be sent $ from users
    function fund() public payable {
        // Allow users to send $
        // Have a minimum $ sent
        // 1e18 is equal to 1 ETH(which is also 1,000,000,000,000,000,000 wei(18-zeros)(which is also 1 * 10 ** 18(in solidity,  ** means exponent)))
        // require means if <first section> is false, then revert with the message of <second section>
        // because we are using the PriceConverter for all uint256, all uint256s now have access to getConversionRate. This way, when we write "msg.value.getConversionRate", the first value will be the first parameter, which is msg.value. So msg.value is ethAmount in the getConversionRate function. If we had a second parameter in the getConversaionRate, the second paramter would be whatever input would be passed into msg.value.getConversionRate() (in this case there is no second value).
        require(msg.value.getConversionRate() >= MINIMUM_USD, "didn't send enough ETH"); // "didn't send enough ETH" is the revert message if it reverts if the user does not send more than 1 eth.
        // msg.value is always in terms of ETH/wei
        // if the require statement fails, then all actions or code that have been executed in that function will revert as well.
        // if you send a failed transaction, you will still spend all as up to that failed transaction, if any remaining gas will be returned to the user.

        // the users whom successfully call this function will be added to the array.
        funders.push(msg.sender);

        // this line keeps track of how much each sender has sent
        // you read it like: mapping(check the mapping) address => amount sent of the sender. So how much the sender sent = how much the sender has sent plus how much he is currently sending.
        // addressToAmountFunded[msg.sender] = addressToAmountFunded[msg.sender] + msg.value;
        //above is the old way. below is the shortcut with += . This += means we are adding the new value to the existing value that already exists.
        addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        // for loop explanation:
        // [1, 2, 3, 4] elements   <-- below
        //  0, 1, 2, 3  indexes    <- so we would loop through the indexes to get all the elements out of this array

        // in a for loop, you first give it the starting index, then the ending index, and then the step amount
        // for example, if you want to go start at the 0th index, end at the 10th index, and increase by 1 every time, then it would be for (uint256 i = 0; i <= 10; i++)
        for (uint256 funderIndex = 0; funderIndex < funders.length; /* length of the funders array */ funderIndex++) {
            /*++ means to add 1 after everytime we go through the following code in the brackets: */
            // we get the index position of the funders array, name this element funder
            address funder = funders[funderIndex];
            // then we reset this funders amount(this is tracked by the mapping of "addressToAmountFunded") to 0 when he withdraws
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);

        // there are three ways to transfer the funds: transfer, send, and call

        // msg.sender is of type address
        // payable(msg.sender) is of type payable address

        // transfers balance from this contract's balance to the msg.sender
        // payable(msg.sender).transfer(address(this).balance); //  this is how you use transfer
        // ^there is an issue with using transfer, as if it uses more than 2,300 gas it will throw and error and revert. (sending tokens from one wallet to another is already 2,100 gas)

        // we need to use "bool" here because when using "send", if the call fails, it will not revert the transaction and the user would not get their money. ("send" also fails at 2,300 gas)
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require sendSuccess to be true or it reverts with "Send Failed"
        // require(sendSuccess, "Send failed");

        // using "call" is lower level solidity and is very powerful, is the best one to use most of the time.
        // "call" can be used to call almost every function in all of ethereum without having an ABI!
        // using "call" returns a boolean and bytes data. The bytes arent important here so we commented it out and left the comma. (but really we would delete it if this was a production contract and we would leave the comma. however if we were calling a function we would keep the bytes data) (bytes objects are arrays which is why we use the memory keyword).
        (bool callSuccess, /* bytes memory dataReturned */ ) = payable(msg.sender).call{value: address(this).balance}(
            "" /*<- this is where we would put info of another function if we were calling another function(but we arent here so we leave it blank) */
        );
        //        calls the value to send to the payable(msg.sender)^

        // require callSuccess to be true or it reverts with "Call Failed"
        require(callSuccess, "Call Failed");
    }

    modifier onlyOwner() {
        // requires the owner to be the only person allowed to call this withdraw function or reverts with "Must be Owner!"
        // require(msg.sender == i_owner, "Must be Owner!");

        // changed to use custom errors to save a ton of gas since. This saves alot of gas since we do not need to store and emit the revert Strings if the require statement fails.
        // this says that if the sender of the message is not the owner, then revert with custom error NotOwner.
        if (msg.sender != i_owner) {
            revert NotOwner();
        }

        // always needs to be in the modifier because modifiers are executed first in functions, then this underscore shows that after the modifier code is executed, to then go on and execute the code in the fucntion with the modifier.
        _;
        // if we had the underscore above the logic in this modifier, this means that we would execute the logic in the function with this modifier first and then execute the modifier's logic. So the order of the underscore matters!!!
    }

    // receive function is called when a transaction is sent to a contract that has no data. it can have not not have funds, but if it has no data, it will be received by the receive function. (the contract needs to have a receive function)
    receive() external payable {
        fund();
    }

    // fallback function is called when a transaction is sent to a contract with data, for example like if a user calls a function that does not exist, then it will be handled by the fallback function. (the contract needs to have a fallback function). the fallback function can also be used if the receive function is not defined.
    fallback() external payable {
        fund();
    }

    // Note: view functions use gas when called by a contract but not when called by a person.

    // if something is "unchecked", then that means when a value hits its max + 1, it will reset to 0.
    // after 0.8.0 of solidity, if a number reaches its max, the number will then fail instead of reseting. instead of overflowing or underflowing, it just fails.
}
