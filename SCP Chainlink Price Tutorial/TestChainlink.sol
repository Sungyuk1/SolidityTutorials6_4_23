// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

//https://www.youtube.com/watch?v=PSJarTvQvtE
contract TestChainlink{
    AggregatorV3Interface internal priceFeed;

    constructor(){
        //Eth to USD price feed. Put in contract address to price feed
        //This is an address deployed on mainnet. Can find other price on the chainlink documentation.
        //0x5f4ec3df9cbd43714fe2740f5e3616155c5b8419
        priceFeed = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419); 

    }

    //Call the latestRoundData() on the interface to get the price in the latest round
    function getLatestPrice() public view returns (int){
        (uint80 roundID, int price, uint startedAt, uint timeStamp, uint80 answeredInRound) = priceFeed.latestRoundData();
        //for ETH / USD price is scaled up by 10 ** 8 
        return price/1e8;
    }

}

/*interface AggregatorV3Interface {
    function latestRoundData() external view returns(
        uint80 roundId, 
        int answer,
        uint startedAt,
        uint updatedAt,
        uint80 answeredInRound
    );
    
}*/