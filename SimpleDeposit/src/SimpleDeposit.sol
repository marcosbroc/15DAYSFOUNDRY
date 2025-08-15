// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract SimpleDeposit {
    uint256 public amt;

    function deposit(uint256 _amt) public returns (uint256) {
        amt += _amt;
        return _amt;
    }

    function withdraw(uint256 _amt) public returns (uint256) {
        require(amt >= _amt);
        amt -= _amt;
        return _amt;
    }
}
