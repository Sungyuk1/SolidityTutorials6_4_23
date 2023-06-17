// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./IERC20.sol";
import "./IWETHGateway.sol";

/*
The depositor will deploy the escrow contract and deposit ether funds. 
This ether should be transferred from the contract to the AAVE lending pool.
One tricky aspect here is that the AAVE lending pool contract is designed to work with ERC20 Tokens. 
We'll need to use Wrapped Ether or WETH if we want to deposit ether into the lending pool.
Fortunately, AAVE deployed a WETHGateway that we can deposit our ether directly into. 
This gateway will convert ether into weth and deposit it into the AAVE lending pool for us. 
In return, the escrow will receive aWETH, an interest bearing asset.
*/

//This is an Escrow Contract that earns interest on AAVE while the Eth is held in Escrow
contract Escrow {
    address arbiter;
    address payable depositor;
    address payable beneficiary;
    uint s_initalDeposit;
    
    IWETHGateway gateway = IWETHGateway(0xDcD33426BA191383f1c9B431A342498fdac73488);
    IERC20 aWETH = IERC20(0x030bA81f1c18d280636F32af80b9AAd02Cf0854e);

    constructor(address _arbiter, address payable _beneficiary) payable {
        arbiter = _arbiter;
        beneficiary = _beneficiary;
        depositor = msg.sender;
        s_initalDeposit = msg.value;

        // TODO: Deposit ETH through the WETH gateway - this is how we send eth to a payable function
        gateway.depositETH{value: address(this).balance}(address(this), 0);
        
    }

    //Here we are approving the IWETH Gateway access to all of our aave interest bearing wrapped eth
    //If you set the amount to be type(uint256).max, the gateway will withdraw your entire balance. 
    //This is also true for the approve method on aTokens.
    function approve() external {
        require(msg.sender == arbiter);
        aWETH.approve(0xDcD33426BA191383f1c9B431A342498fdac73488, type(uint256).max);
        gateway.withdrawETH(type(uint256).max, address(this));

        //After we withdraw the eth from aave, send the initial deposit to the beneficiary, and the interest 
        //earned while in the escrow to the depositor
        beneficiary.transfer(s_initalDeposit);
        depositor.transfer(address(this).balance);

    }

    //allow contract to recieve ether
    receive() external payable {}
    fallback() external payable {}

}