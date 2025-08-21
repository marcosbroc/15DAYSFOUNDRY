// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// Build a mintable token using OpenZeppelin. Learn to install and manage dependencies cleanly.

import {ERC20} from "@openzep/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract ERC20Mintable is Ownable, ERC20 {
    constructor() ERC20("Marcoin", "MARC") Ownable(msg.sender) {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }
}
