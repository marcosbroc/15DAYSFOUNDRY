// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SimpleDeposit} from "../src/SimpleDeposit.sol";

contract SimpleDepositTest is Test {
    SimpleDeposit public simpleDeposit;

    function setUp() public {
        simpleDeposit = new SimpleDeposit();
    }

    function test_Deposit() public {
        uint256 amount = simpleDeposit.deposit(5);
        assertEq(amount, 5);
    }

    function testFuzz_Deposit(uint256 x) public {
        console.log("Hello");
        uint256 amount = simpleDeposit.deposit(x);
        assertEq(amount, x);
    }
}
