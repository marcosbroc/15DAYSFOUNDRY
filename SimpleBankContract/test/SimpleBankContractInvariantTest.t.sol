// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SimpleBankContract} from "../src/SimpleBankContract.sol";

contract SimpleBankContractInvariantTest is Test {
    SimpleBankContract public bank;
    address public user1 = address(0x1);
    address public user2 = address(0x2);
    address[] public users;

    function setUp() public {
        bank = new SimpleBankContract();
        users = [address(0x1), address(0x2), address(0x3)];
        for (uint i = 0; i < users.length; i++) {
            vm.deal(users[i], 100 ether);
        }
    }

    function invariant_depositEqualsContractBalance() public view {
        assertEq(bank.totalDeposits(), address(bank).balance);
    }

    function invariant_totalDepositMatchUserBalance() public view {
        uint256 sumOfBalances = 0;
        for (uint256 i = 0; i < users.length; i++) {
            sumOfBalances += bank.balances(users[i]);
        }
        assertEq(sumOfBalances, bank.totalDeposits());
    }

    function deposit(uint256 _amt) public {
        bank.deposit{value: _amt}();
    }

    function withdraw(uint256 amount, uint256 userIndex) public {
        address user = users[userIndex % users.length];
        uint256 userBalance = bank.balances(user);

        if (userBalance == 0) return;

        amount = bound(amount, 1, userBalance);
        vm.prank(user);
        bank.withdraw(amount);
    }

    function testFuzzWithdraw(
        uint256 depositAmount,
        uint256 withdrawAmount
    ) public {
        vm.assume(depositAmount > 0 && depositAmount <= 10 ether);
        vm.assume(withdrawAmount > 0 && depositAmount <= depositAmount);

        vm.prank(user1);
        bank.deposit{value: depositAmount}();

        uint256 initialBalance = user1.balance;

        vm.prank(user1);
        bank.withdraw(withdrawAmount);

        assertEq(bank.balances(user1), depositAmount - withdrawAmount);
        assertEq(user1.balance, initialBalance + withdrawAmount);
        assertEq(bank.totalDeposits(), depositAmount - withdrawAmount);
    }
}
