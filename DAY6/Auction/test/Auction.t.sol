// SPDX-License-Identifier: MIT
// This file is part of the 15 Days of Foundry challenge.
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {Auction} from "../src/Auction.sol";

contract AuctionTest is Test {
    Auction auction;

    function setUp() public {
        auction = new Auction(3 hours);
    }

    function testAddItem() public {
        auction.setItem("Cristiano Ronaldo's beach slippers", 100);

        Auction.AuctionedItem memory item = auction.getItem(0);
        assertEq(item.description, "Cristiano Ronaldo's beach slippers");
        assertEq(item.startingPrice, 100);
        assertEq(item.auctionStart, block.timestamp);
        assertEq(item.auctionEnd, block.timestamp + 3 hours);
        assertEq(item.highestBidder, address(0));
        assertEq(item.highestBid, 0);
        assertEq(item.isAvailable, true);
        console.log("Minutes left for item 0 is ", item.auctionEnd - block.timestamp);
    }

    function testBid() public {
        auction.setItem("Julio Iglesias hair comb", 100);
        auction.setItem("Lionel Messi's lucky socks", 150);
        auction.bid(0, 100);
        auction.bid(1, 200);

        vm.expectRevert("Current bid is not beating highest bid");
        auction.bid(1, 150);
        Auction.AuctionedItem memory item = auction.getItem(0);
        assertEq(item.highestBidder, address(this));
        assertEq(item.highestBid, 100);
    }

    function testEndAuction() public {
        // Set items
        auction.setItem("Item 1", 100);
        auction.setItem("Item 2", 50);
        vm.prank(address(0x111));
        auction.bid(1, 50);
        vm.warp(block.timestamp + 3 hours - 5);
        auction.bid(0, 150);
        vm.warp(block.timestamp + 180);
        vm.prank(address(0x123));
        auction.bid(0, 151);
        vm.warp(block.timestamp + 3 hours);

        // Check first but ignore the rest (making sure there is no mismatch of indexed fields)
        vm.expectEmit(true, true, false, false);
        emit Auction.itemGone(0, address(0x123), 50);
        auction.endAuction();
        Auction.AuctionedItem memory item = auction.getItem(0);
        assertEq(item.isAvailable, false);
        item = auction.getItem(1);
        assertEq(item.isAvailable, false);
    }
}
