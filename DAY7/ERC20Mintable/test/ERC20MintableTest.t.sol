// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {ERC20Mintable} from "../src/ERC20Mintable.sol";

contract ERC20MintableTest is Test {
    ERC20Mintable public token;
    address public owner = address(0x1);
    address public address1 = address(0x123);
    address public address2 = address(0x456);

    function setUp() public {
        vm.prank(owner);
        token = new ERC20Mintable();
    }

    function test_Mint() public {
        uint256 initialBalance1 = token.balanceOf(address1);
        uint256 initialBalance2 = token.balanceOf(address2);
        vm.startPrank(owner);
        token.mint(address1, 100);
        token.mint(address2, 50);
        assertEq(token.balanceOf(address1), initialBalance1 + 100);
        assertEq(token.balanceOf(address2), initialBalance2 + 50);

        console.log(token.name(), token.symbol());
        console.log("Balance 1:", token.balanceOf(address1), ", balance 2:", token.balanceOf(address2));

        initialBalance2 = token.balanceOf(address2);
        console.log(initialBalance2);
        vm.stopPrank();

        vm.prank(address2);
        token.burn(initialBalance2 / 2);
        console.log("Burnt amount", initialBalance2 / 2, "Current balance", token.balanceOf(address2));
    }
}
