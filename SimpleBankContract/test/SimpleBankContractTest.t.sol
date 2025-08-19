// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SimpleBankContract} from "../src/SimpleBankContract.sol";

contract SimpleBankContractTest is Test {
    SimpleBankContract public simpleBankContract;
    address public user1 = address(0x1);
    address public user2 = address(0x2);

    function setUp() public {
        simpleBankContract = new SimpleBankContract();
        vm.deal(user1, 100 ether);
        vm.deal(user2, 100 ether);
    }

    function testFuzz_Deposit(uint256 _amount) public {
        // Check only from more than zero to 10
        vm.assume(_amount > 0);
        vm.assume(_amount <= 10 ether);

        vm.prank(user1); // Set the user address for the next statement
        simpleBankContract.deposit{value: _amount}();

        assertEq(simpleBankContract.balances(user1), _amount);
        assertEq(simpleBankContract.totalDeposits(), _amount);
        assertEq(address(simpleBankContract).balance, _amount);
    }
}
