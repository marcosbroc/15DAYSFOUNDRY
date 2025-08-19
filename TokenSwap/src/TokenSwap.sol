// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenSwap {
    IERC20 private tokenA;
    IERC20 private tokenB;

    constructor(address _tokenA, address _tokenB) {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }

    function swapAtoB(uint256 amount) external {
        // Ensure the amount of tokens to be redeemed is greater than zero
        require(amount > 0, "Amount must be greater than zero");

        // Ensure the caller has enough A tokens
        require(tokenA.balanceOf(msg.sender) >= amount, "Sender doesn't have enough A tokens to provide");

        // Ensure the contract has enough B tokens to return
        require(tokenB.balanceOf(address(this)) >= amount, "Contract doesn't have enough B tokens to return");

        // Take token A from the user
        require(tokenA.transferFrom(msg.sender, address(this), amount), "Provision of token A failed");

        // Send token B from contract to the user
        require(tokenB.transfer(msg.sender, amount), "Return of token B failed");
    }

    function swapBtoA(uint256 amount) external {
        // Ensure the amount of tokens to be redeemed is greater than zero
        require(amount > 0, "Amount must be greater than zero");

        // Ensure the caller has enough B tokens
        require(tokenB.balanceOf(msg.sender) >= amount, "Sender doesn't have enough B tokens to provide");

        // Ensure the contract has enough A tokens to return
        require(tokenA.balanceOf(address(this)) >= amount, "Contract doesn't have enough A tokens to return");

        // Take token B from the user
        require(tokenB.transferFrom(msg.sender, address(this), amount), "Provision of token B failed");

        // Send token A from contract to the user
        require(tokenA.transfer(msg.sender, amount), "Return of token A failed");
    }
}
