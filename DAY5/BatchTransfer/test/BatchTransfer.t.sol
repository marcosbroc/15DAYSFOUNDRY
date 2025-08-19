// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {BatchTransfer} from "../src/BatchTransfer.sol";

contract BatchTransferTest is Test {
    BatchTransfer batchTransfer;
    address public owner = address(0x1);
    address public user1 = address(0x2);
    address public user2 = address(0x3);
    address public user3 = address(0x4);

    function setUp() public {
        vm.prank(owner);
        batchTransfer = new BatchTransfer();
    }

    function test_addTransfer() public {
        vm.startPrank(owner);
        batchTransfer.addTransfer(user1, "iPhone XS", 1 ether);
        batchTransfer.addTransfer(user2, "iPhone 11", 2 ether);
        batchTransfer.addTransfer(user3, "iPhone 15", 4 ether);
    }

    function test_processTransfer() public {
        test_addTransfer();

        // Fund the contract
        vm.deal(address(batchTransfer), 10 ether);

        vm.startPrank(owner);
        batchTransfer.processTransfer();
        /*
        // Check if the transfers were processed
        for (uint256 i = 0; i < 3; i++) {
            BatchTransfer.Transfer memory transfer = batchTransfer.getTransfer(i);
            assertTrue(transfer.isProcessed, "Transfer should be marked as processed");
        }*/
    }
}
