// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

//https://www.youtube.com/watch?v=P-4ucHdjGpU

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CrowdFund{

    //putting indexed on the creator so that we can find all the campagins started by the same creator
    event Launch(uint id, 
    address indexed creator, 
    uint goal,
    uint32 startAt,
    uint32 endAt);

    event Cancel(uint id);

    event Pledge(uint indexed id, address indexed caller, uint amount);

    event Unpledge(uint indexed id, address indexed caller, uint amount);

    event Claim(uint id);

    event Refund(uint indexed id, address indexed caller, uint amount);


    //A struct for a Campaign - like a class
    //If you define your struct in your contract, it is treated as state variable, 
    //but you can also declare it outside of you contract and import it in another contract 
    //You can also use your struct in a function, with the storage keyword you access the state directly, while the memory keyword will copy it in memory.
    struct Campaign {
        address s_creator;
        uint s_goal;
        uint s_pledged;
        uint32 s_startAt;
        uint32 s_endAt;
        bool s_claimed;
    }

    //Each Crowdfunding campagin will only support a single token for security reasons
    IERC20 public immutable s_token;
    //Mappings in solidity are always stored in the storage 
    mapping(uint => Campaign) public s_campaigns;

    //increment count for each campaign
    uint public s_count;
    
    //mapping for how much each user has donated per campaign
    mapping(uint => mapping(address => uint)) public s_pledgeAmount;

    constructor(address _token){
        s_token = IERC20(_token);
    }


    function launch(uint _goal, uint32 _startAt, uint32 _endAt) external {
        require(_startAt >= block.timestamp, "start at < now");
        require(_endAt >= _startAt, "End at < start at");
        require(_endAt <= block.timestamp + 90 days, "end at > max duration");

        s_count += 1;
        s_campaigns[s_count] = Campaign({
            s_creator: msg.sender,
            s_goal: _goal,
            s_pledged: 0, 
            s_startAt :_startAt,
            s_endAt : _endAt,
            s_claimed: false
        });

        emit Launch(s_count, msg.sender, _goal, _startAt, _endAt);

    }


    //functions that can be called while the campaign is going on

    //Cancel a Campaign
    function cancel(uint _id) external {
        Campaign memory campagin = s_campaigns[_id];
        require(msg.sender == campagin.s_creator, "Only the creator may cancel the campaign");
        require(block.timestamp < campagin.s_startAt, "Campaign not yet started");
        emit Cancel(_id);


    }

    //allows users to pledge their cryptocurrencies to the campaign    
    function pledge(uint _id, uint _amount) external {
        //declaring it as storage since we will need to update the campaign struct
        Campaign storage campaign = s_campaigns[_id];
        require(block.timestamp >= campaign.s_startAt, "Not Started");
        //Users will not be able to pledge to a campaign that does not exist either. A campagin that does not exist will have an endAt that is zero
        require(block.timestamp <= campaign.s_endAt, "Campagin Ended");

        //always transfer then update
        s_token.transferFrom(msg.sender, address(this), _amount);
        campaign.s_pledged += _amount;
        s_pledgeAmount[_id][msg.sender] += _amount;

        emit Pledge(_id, msg.sender, _amount);

    }

    //Allows users to unpledge the tokens that they have pledged
    function unpledge(uint _id, uint _amount) external{
        Campaign storage campaign = s_campaigns[_id];
        require(block.timestamp <= campaign.s_endAt, "Campaign has Ended");

        campaign.s_pledged -= _amount;
        s_token.transfer(msg.sender, _amount);
        emit Unpledge(_id, msg.sender, _amount);

    }

    //functions that can be called after the campaign is over

    //successful campaign
    function claim(uint _id) external {
        Campaign storage campaign = s_campaigns[_id];
        require(msg.sender == campaign.s_creator, "Sender is not the creator of this campaign");
        require(block.timestamp > campaign.s_endAt, "Not Ended");
        require(campaign.s_pledged >= campaign.s_goal, "Pledged less than goal");
        require(!campaign.s_claimed, "Already claimed");

        campaign.s_claimed = true;
        s_token.transfer(msg.sender, campaign.s_pledged);

        emit Claim(_id);

    }

    //unsuccessful campagign. 
    function refund(uint _id) external {
        Campaign storage campaign = s_campaigns[_id];
        require(block.timestamp > campaign.s_endAt, "Not Ended");
        require(campaign.s_pledged <= campaign.s_goal, "Pledged less than goal");
        
        //Change variables before transfering to prevent reentrancy attacks
        uint bal = s_pledgeAmount[_id][msg.sender];
        s_pledgeAmount[_id][msg.sender] = 0;
        s_token.transfer(msg.sender, bal);

        emit Refund(_id, msg.sender, bal);


    }
}