//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract SimpleBank {
    mapping(address => uint32) private accounts;

    function deposit(uint32 amount) public {
        require(amount > 0, "The amount to deposit must be greater than zero");
        accounts[msg.sender] = accounts[msg.sender] + amount;
    }

    function withdraw(uint32 amount) public {
        require(amount > 0, "The amount to withdraw must be greater than zero");
        require(accounts[msg.sender] >= amount);
        accounts[msg.sender] = accounts[msg.sender] - amount;
    }
}
