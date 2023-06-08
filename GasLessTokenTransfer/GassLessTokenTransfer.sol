// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

//https://www.youtube.com/watch?v=jYNnatXRsBs 

import "./IERC20Permit.sol";
//Note that the standard IERC20 does not have a function called permit. This is why we use IERC20Permit

contract GasLessTokenTransfer{
    function send(
        address token,
        address sender,
        address reciever, 
        uint amount,
        uint fee,
        uint256 deadline,
        uint8 v, 
        bytes32 r, 
        bytes32 s
    ) external {
        IERC20Permit(token).permit(sender, address(this), amount+fee, deadline, v, r, s);
        IERC20Permit(token).transferFrom(sender, reciever, amount);
        IERC20Permit(token).transferFrom(sender, reciever, fee);

    }
}