// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

//https://www.youtube.com/watch?v=P-4ucHdjGpU

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CrowdFund{

    //A struct for a Campaign - like a class
    //If you define your struct in your contract, it is treated as state variable, 
    //but you can also declare it outside of you contract and import it in another contract 
    //You can also use your struct in a function, with the storage keyword you access the state directly, while the memory keyword will copy it in memory.
    struct Campaign {
        address s_creator;
        uint s_goal;
        uint32 s_startAt;
        uint32 s_endAt;
        bool s_claimed;
    }

    //Each Crowdfunding campagin will only support a single token for security reasons
    IERC20 public immutable s_token;
    //Mappings in solidity are always stored in the storage 
    mapping(uint => Campaign) public campaigns;


    function launch(uint _goal, uint32 _startAt, uint32 _endAt) external {

    }


    //functions that can be called while the campaign is going on

    //Cancel a Campaign
    function cancel(uint _id) external {

    }

    //allows users to pledge their cryptocurrencies to the campaign    
    function pledge(uint _id, uint _amount) external {

    }

    //Allows users to unpledge the tokens that they have pledged
    function unpledge(uint _id, uint _amount) external{

    }

    //functions that can be called after the campaign is over

    //successful campaign
    function claim(uint _id) external {

    }

    //unsuccessful campagign. 
    function refund(uint _id) external {

    }
}