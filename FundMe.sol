// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";

contract FundMe {
    using PriceConverter for uint256;
    
    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;
    address public owner;
    
    constructor() {
        owner = msg.sender;
    }

    function fund() public payable {
        uint256 minimumUSD = 50 * 10 ** 18;
        require(msg.value.getConversionRate() >= minimumUSD, "You need to spend more ETH!");
        // require(PriceConverter.getConversionRate(msg.value) >= minimumUSD, "You need to spend more ETH!");
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
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
        require(msg.sender == owner);
        _;
    }
    
    function withdraw() payable onlyOwner public {
        payable(msg.sender).transfer(address(this).balance);
        for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
    }
}



