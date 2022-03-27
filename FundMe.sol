// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";

error NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    event Funded(address indexed from, uint256 amount);
    
    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;
    // Could we make this constant? 
    address public /* immutable */ owner;
    
    constructor() {
        owner = msg.sender;
    }

    function fund() public payable {
        uint256 minimumUSD = 50 * 10 ** 18;
        require(msg.value.getConversionRate() >= minimumUSD, "You need to spend more ETH!");
        // require(PriceConverter.getConversionRate(msg.value) >= minimumUSD, "You need to spend more ETH!");
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
        emit Funded(msg.sender, msg.value);
    }
    
    function getVersion() public view returns (uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        return priceFeed.version();
    }
    
    // function getPrice() public view returns(uint256){
    //     AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
    //     (,int256 answer,,,) = priceFeed.latestRoundData();
    //      // ETH/USD rate in 18 digit 
    //      return uint256(answer * 10000000000);
    // }
    
    // 1000000000
    // function getConversionRate(uint256 ethAmount) public view returns (uint256){
    //     uint256 ethPrice = getPrice();
    //     uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
    //     // the actual ETH/USD conversation rate, after adjusting the extra 0s.
    //     return ethAmountInUsd;
    // }
    
    modifier onlyOwner {
        // require(msg.sender == owner);
        if (msg.sender != owner) revert NotOwner();
        _;
    }
    
    function withdraw() payable onlyOwner public {
        for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        // payable(msg.sender).transfer(address(this).balance);
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        // call vs delegatecall
        require(success, "Transfer failed");
    }
    // Explainer from: https://solidity-by-example.org/fallback/
    // Ether is sent to contract
    //      is msg.data empty?
    //          /   \ 
    //         yes  no
    //         /     \
    //    receive()?  fallback() 
    //     /   \ 
    //   yes   no
    //  /        \
    //receive()  fallback()

    fallback() external payable {
        fund();
    }

    recieve() external payable {
        fund();
    }
}

// Concepts we didn't cover yet (will cover in later sections)
// 1. Enum
// 2. Try / Catch
// 3. Function Selector
// 4. abi.encode / decode
// 5. Hash with keccak256
// 6. Yul / Assembly



