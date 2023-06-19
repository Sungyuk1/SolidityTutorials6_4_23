//SPDX-License-Identifier: Unlicense
pragma solidity ^0.7.5;

import "./IERC20.sol";
import "./ILendingPool.sol";

contract Escrow {
    address arbiter;
    address depositor;
    address beneficiary;
    uint s_initial_deposit;

    // the mainnet AAVE v2 lending pool
    ILendingPool pool = ILendingPool(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9);
    // aave interest bearing DAI
    IERC20 aDai = IERC20(0x028171bCA77440897B824Ca71D1c56caC55b68A3);
    // the DAI stablecoin 
    IERC20 dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);

    constructor(address _arbiter, address _beneficiary, uint _amount) {
        arbiter = _arbiter;
        beneficiary = _beneficiary;
        depositor = msg.sender;
        s_initial_deposit = _amount;

        // TODO: transfer dai to this contract
        dai.transferFrom(msg.sender, address(this), _amount);

        // Approve Spend - pool address is first input
        dai.approve(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9, _amount);

        //function deposit(address asset, uint256 amount, address onBehalfOf, uint16 referralCode) - dai address is first input
        pool.deposit(0x6B175474E89094C44Da98b954EedeAC495271d0F, _amount, address(this), 0);
    }

    function approve() external {
        require(msg.sender == arbiter);

        //function withdraw(address asset, uint256 amount, address to)
        //Withdraws amount of the underlying asset, i.e. redeems the underlying token and burns the aTokens.
        pool.withdraw(0x6B175474E89094C44Da98b954EedeAC495271d0F, s_initial_deposit, beneficiary);
        pool.withdraw(0x6B175474E89094C44Da98b954EedeAC495271d0F, aDai.balanceOf(address(this)), depositor);

    }
}
