//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract SimpleBank {
    mapping(address => uint64) private accounts;

    function deposit(uint64 amount) public {
        require(amount > 0, "The amount to deposit must be greater than zero");
        accounts[msg.sender] = accounts[msg.sender] + amount;
    }

    function withdraw(uint64 amount) public {
        require(amount > 0, "The amount to withdraw must be greater than zero");
        require(amount <= accounts[msg.sender], "Not enough balance");
        accounts[msg.sender] = accounts[msg.sender] - amount;
    }

    function getBalance() public view returns (uint64) {
        return accounts[msg.sender];
    }

    function transfer(address destinationAccount, uint64 amount) public {
        require(amount > 0, "The amount to transfer must be greater than zero");
        require(amount <= accounts[msg.sender], "Not enough balance");
        require(destinationAccount != address(0), "Invalid destination");
        accounts[msg.sender] = accounts[msg.sender] - amount;
        accounts[destinationAccount] = accounts[destinationAccount] + amount;
    }
}
