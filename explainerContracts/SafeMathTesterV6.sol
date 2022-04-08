// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract SafeMathTester{
    uint8 public bigNumber = 255; // unchecked

    function add() public {
        bigNumber = bigNumber + 1;
    }
}