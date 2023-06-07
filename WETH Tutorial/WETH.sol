// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

//https://www.youtube.com/watch?v=UqKQ1bTatUs 


//Stands fro Wrapped Eth. Contract that Wraps eth into an ERC20. 
//When you give the contract ETH, a token is minted, and when you burn a token the ETH is given back
//Weth is used in many common Defi Protocols - instead of having to write two contracts, one for Eth and one for ERC20, you can just use weth if you want to 
//support eth.
contract WETH is ERC20{ 

    event Deposit(address indexed account, uint amount);
    event Withdraw(address indexed account, uint amount);

    //ERC 20 default constructor takes Name, Symbol and decimal
    constructor() ERC20("Wrapped Ether", "WETH") {}

    //when a user sends eth, mint erc20 for them
    function deposit() public payable {
        //_mint inherited from ERC20
        _mint(msg.sender, msg.value);
        emit Deposit(msg.sender, msg.value);
    }

    fallback() external payable{
        deposit();
    }

    receive() external payable {
        // custom function code
    }

    //When a user withdraws, burn tokens and then return eth
    function withdraw(uint _amount) external{
        //ERC20 burn method - also burn before sending to prevent reentrancy
        _burn(msg.sender, _amount);
        payable(msg.sender).transfer(_amount);
        emit Withdraw(msg.sender, _amount);

    }




}