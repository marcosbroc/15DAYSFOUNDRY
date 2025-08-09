// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Greeting {
    string public greetingMessage;

    function getGreeting(
        string memory _name
    ) public view returns (string memory) {
        if (bytes(_name).length > 0)
            // The way to concatenate strings in Solidity
            return string(abi.encodePacked(greetingMessage, " ", _name));
        else return greetingMessage;
    }

    function setGreetingMessage(string memory _greetingMessage) public {
        greetingMessage = _greetingMessage;
    }
}
