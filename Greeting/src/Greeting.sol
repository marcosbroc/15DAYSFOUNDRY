// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Greeting {
    string public greeting;

    function getGreeting(
        string memory _name
    ) public view returns (string memory) {
        if (bytes(_name).length > 0)
            // The way to concatenate strings in Solidity
            return string(abi.encodePacked(greeting, " ", _name));
        else return greeting;
    }

    function setGreeting(string memory _greeting) public {
        greeting = _greeting;
    }
}
