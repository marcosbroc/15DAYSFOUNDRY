// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SimpleShop} from "../src/SimpleShop.sol";

contract SimpleShopTest is Test {
    SimpleShop public shop;

    address public owner = address(0x1);
    address public user1 = address(0x2);
    address public user2 = address(0x3);

    function setUp() public {
        vm.prank(owner);
        shop = new SimpleShop();

        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);
    }

    function test_gas_addItem() public {
        vm.prank(owner);

        uint256 gasBefore = gasleft();
        shop.addItem("Apple", 1 ether, 100);
        uint256 gasUsed = gasBefore - gasleft();
        console.log("Gas used for addItem: ", gasUsed);
    }

    function test_gas_multiplePurchase() public {
        vm.prank(owner);
        shop.addItem("Apple", 1 ether, 100);

        vm.prank(user1);
        uint256 gasBefore = gasleft();
        shop.purchaseItem{value: 1 ether}(0, 1);
        uint256 firstPurchaseGas = gasBefore - gasleft();

        vm.prank(user2);
        gasBefore = gasleft();
        shop.purchaseItem{value: 1 ether}(0, 1);
        uint256 secondPurchaseGas = gasBefore - gasleft();
        console.log("First purchase gas: ", firstPurchaseGas);
        console.log("Second purchase gas: ", secondPurchaseGas);
        console.log(
            "Difference: ",
            int256(firstPurchaseGas) - int256(secondPurchaseGas)
        );
    }
}
