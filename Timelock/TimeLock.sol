// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;


//https://www.youtube.com/watch?v=P1f2a5Ckjpg&t=3s

//Commonly used in defi protocls. The point is to delay a transaction. 
//First you will broadcast the transaction that you will execute by calling the function queue
//Then you have to wait a given amount of time
//Then you can execute using the execute function

//Potential news, if an update is coming to the contract, it gives your users time to examine the changes.
//If the users do not like the changes, they will have time to withdrawl their funds before the changes take place

//The purpose of this is to create trust between the users of a protocol and the owner that no malicious last second changes will be made to 
//the protocol
contract TimeLock{
    error NotOwnerError();
    error AlreadyQueuedError(bytes32 txId);
    error TimestampNotInRangeError(uint blockTimestamp, uint timestamp);
    error NotQueuedError(bytes32 txId);
    error TimestampNotPassedError(uint blockTimestamp, uint timestamp);
    error TimestampExpiredError(uint blockTimestamp, uint expiresAt);
    error TxFailedError();

    event Execute( 
        bytes32 indexed txId,
        address _target,
        uint value, 
        string _func,
        bytes _data,
        uint _timestamp);


    event Queue( 
        bytes32 indexed txId,
        address _target,
        uint value, 
        string _func,
        bytes _data,
        uint _timestamp);

    event Cancel(bytes32 indexed txId);

    //using 10 seconds since we do not have to wait several days to test this code
    uint public constant MIN_DELAY = 10;
    uint public constant MAX_DELAY = 1000;
    uint public constant GRACE_PERIOD = 1000;

    address public s_owner;

    constructor(){
        s_owner = msg.sender;
    }

    receive() external payable{}

    mapping(bytes32 => bool) public m_queued;

    function getTxId( 
        address _target,
        uint _value, 
        string calldata _func,
        bytes calldata _data,
        uint _timestamp) public pure returns(bytes32 txId){
            return keccak256(
                abi.encode(
                    _target, _value, _func, _data, _timestamp
                )
            );

        }

    modifier onlyOwner(){
        if (msg.sender != s_owner){
            revert NotOwnerError();
        }
        _;
    }


    function queue(
        address _target,
        uint _value, 
        string calldata _func,
        bytes calldata _data,
        uint _timestamp
    ) external onlyOwner{
        // create tx id
        bytes32 txId = getTxId(_target, _value, _func, _data, _timestamp);

        //check tx id is unique
        if (m_queued[txId]){
            revert AlreadyQueuedError(txId);
        }

        //check timestamp
        if (_timestamp < block.timestamp + MIN_DELAY || _timestamp > block.timestamp + MAX_DELAY){
            revert TimestampNotInRangeError(block.timestamp, _timestamp);
        }

        //queue tx
        m_queued[txId] = true;

        emit Queue(txId, _target, _value, _func, _data, _timestamp);
    }

    //executes a transaction which has been queued
    function execute(
        address _target,
        uint _value, 
        string calldata _func,
        bytes calldata _data,
        uint _timestamp
        ) external payable onlyOwner returns(bytes memory){
            //get tx id
            bytes32 txId = getTxId(_target, _value, _func, _data, _timestamp);
            //check tx i s queued
            if (!m_queued[txId]){
                revert NotQueuedError(txId);
            }
            if (block.timestamp < _timestamp){
                revert TimestampNotPassedError(block.timestamp, _timestamp);
            }
            //check that time is greater than timeStamp
            if(block.timestamp > _timestamp + GRACE_PERIOD){
                revert TimestampExpiredError(block.timestamp, _timestamp + GRACE_PERIOD);
            }
            //execute the tx
            bytes memory data;
            if (bytes(_func).length > 0){
                data = abi.encodePacked(
                    //compute function selector
                    bytes4(keccak256(bytes(_func))),
                    _data
                );
            }else{
                data = _data;
            }
            (bool ok, bytes memory res)=_target.call{value: _value}(data);
            if (!ok){
                //revert if the target.call fails
                revert TxFailedError();
            }

            emit Execute(txId, _target, _value, _func, _data, _timestamp);

            //delete tx from queue
            m_queued[txId] = false;


            return res;
        }

        function cancel(bytes32 _txId) external onlyOwner {
            if (!m_queued[_txId]){
                revert NotQueuedError(_txId);
            }

            m_queued[_txId] = false;
            emit Cancel(_txId);

        }

}