// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/SimpleStore.sol";

contract SimpleStoreGasTest is Test {
    SimpleStore public store;
    address public owner = address(0x1);
    address public user1 = address(0x2);
    address public user2 = address(0x3);

    function setUp() public {
        vm.prank(owner);
        store = new SimpleStore();

        // Give users some ETH
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);
    }

    // 🔥 BASIC GAS TEST: Measure single operation
    function test_gas_addItem() public {
        vm.prank(owner);

        uint256 gasBefore = gasleft(); // Get gas remaining before operation
        store.addItem("Apple", 1 ether, 100);
        uint256 gasUsed = gasBefore - gasleft(); // Calculate gas consumed

        console.log("Gas used for addItem:", gasUsed);
    }

    // 🔥 COMPARATIVE GAS TEST: Multiple operations
    // This shows how gas costs can vary between similar operations
    function test_gas_multiplePurchases() public {
        // Setup
        vm.prank(owner);
        store.addItem("Apple", 1 ether, 100);

        // Test first purchase - often most expensive due to storage initialization
        vm.prank(user1);
        uint256 gasBefore = gasleft();
        store.purchaseItem{value: 1 ether}(0, 1);
        uint256 firstPurchaseGas = gasBefore - gasleft();

        // Test second purchase - usually cheaper because storage slots are already "warm"
        vm.prank(user2);
        gasBefore = gasleft();
        store.purchaseItem{value: 1 ether}(0, 1);
        uint256 secondPurchaseGas = gasBefore - gasleft();

        console.log("First purchase gas:", firstPurchaseGas);
        console.log("Second purchase gas:", secondPurchaseGas);
        console.log("Difference:", int256(firstPurchaseGas) - int256(secondPurchaseGas));

        // The first purchase is typically more expensive because:
        // 1. First time writing to storage costs more (cold storage)
        // 2. Initializing new storage slots costs ~20,000 gas each
        // 3. Subsequent writes to same slots cost only ~5,000 gas
    }
}

contract SimpleStoreSnapshotTest is Test {
    SimpleStore public store;

    function setUp() public {
        store = new SimpleStore();
    }

    function test_snapshot_addItem() public {
        // This will create a snapshot automatically when you run `forge snapshot`
        // The gas usage is recorded with the test name as the identifier
        store.addItem("Apple", 1 ether, 100);
    }

    function test_snapshot_purchaseItem() public {
        // Setup phase - gas usage here is NOT included in snapshot
        store.addItem("Apple", 1 ether, 100);

        // Only this operation's gas is measured and snapshotted
        store.purchaseItem{value: 1 ether}(0, 1);
    }

    function test_snapshot_multipleItems() public {
        // This measures the cumulative gas of adding multiple items
        // Useful for testing batch operations or loops
        store.addItem("Apple", 1 ether, 100);
        store.addItem("Banana", 0.5 ether, 200);
        store.addItem("Cherry", 2 ether, 50);
    }
}
