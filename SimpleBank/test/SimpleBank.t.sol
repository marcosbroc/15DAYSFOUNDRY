// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {SimpleBank} from "../src/SimpleBank.sol";

contract SimpleBankTest is Test {
    SimpleBank public bank;

    function setUp() public {
        bank = new SimpleBank();
    }

    function test_Deposit() public {
        uint64 amountToDeposit = 100;
        uint64 balance = bank.getBalance();
        bank.deposit(amountToDeposit);
        assertEq(bank.getBalance(), balance + amountToDeposit);
    }

    function test_Withdraw() public {
        test_Deposit();
        uint64 amountToWithdraw = 1;
        uint64 balance = bank.getBalance();
        bank.withdraw(amountToWithdraw);
        assertEq(bank.getBalance(), balance - amountToWithdraw);
    }

    function testFuzz_Transfer(address x, uint64 y) public {
        vm.expectRevert(); // This should fail if the address is not valid or not enough balance
        bank.transfer(x, y);
    }
}
