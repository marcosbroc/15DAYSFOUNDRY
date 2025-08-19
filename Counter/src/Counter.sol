// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract Counter {
    // This uint32 per se will not save gas unless we add further logic with more variables in the contract
    uint32 public counter;

    /* From an hypothetical use case, we will assume that the counter should not go below zero.
    Also, I'm experimenting with potential minor gas savings using local variables */
    function decreaseCounter() public returns (uint32) {
        uint32 _counter = counter;
        if (_counter > 0) {
            _counter--;
            counter = _counter;
        }
        return _counter;
    }

    /* No gas to save here from using a local variable as we only access 'counter' once */
    function increaseCounter() public returns (uint32) {
        counter++;
        return counter;
    }
}
