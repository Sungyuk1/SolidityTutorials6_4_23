// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

//https://www.youtube.com/watch?v=4w_bMkoo2uw

//Tutorial - anyone can send crypto in, only owner can take it out
contract EtherWallet{
    address payable public s_owner;

    constructor(){
        s_owner = payable(msg.sender);
    }

    //enable the contract to recieve ether. This reciece can also be acomplished by a Fallback and 
    //it will acomplish the same thing. But this makes our intentions clear
    receive() external payable{}

    function withdraw(uint _amount) external{
        require(msg.sender == s_owner, "caller is not owner");
        //s_owner.transfer(_amount);
        //Optimize for gas. Since due to the require we know that msg.sender is equal to s_owner, we can transfer using msg.sender instead of owner 
        //to save on gas by preventing a sload
        payable(msg.sender).transfer(_amount);
    }

    function getBalance() external view returns (uint){
        return address(this).balance;
    }

}