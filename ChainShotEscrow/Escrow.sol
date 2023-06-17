// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Escrow {
    address public depositor;
    address payable public beneficiary;
    address public arbiter;
    
    constructor(address _arbiter, address payable _beneficiary) payable {
        depositor = msg.sender;
        arbiter = _arbiter;
        beneficiary = _beneficiary;
    }

    function approve() external{
        if(msg.sender != arbiter){
            revert("You are not the arbiter");
        }
        beneficiary.transfer(address(this).balance);
    }
}