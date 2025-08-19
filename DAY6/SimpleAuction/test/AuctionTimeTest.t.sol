// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SimpleAuction} from "../src/SimpleAuction.sol";

contract TimeManipulationTest is Test {
    SimpleAuction auction;

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    event AuctionExtended(uint256 newEndTime);
    uint256 startTime;

    function setUp() public {
        startTime = block.timestamp;
        auction = new SimpleAuction(1 hours);

        vm.deal(alice, 10 ether);
        vm.deal(bob, 10 ether);
    }

    function test_timeLeftOverPeriod() public {
        assertEq(auction.timeLeft(), 1 hours);

        vm.warp(startTime + 30 minutes);
        assertEq(auction.timeLeft(), 30 minutes);

        vm.warp(auction.timeLeft() + 30 minutes);
        assertEq(auction.timeLeft(), 0);
    }

    function test_cannotBidAfterEnd() public {
        vm.warp(startTime + 1 hours + 1);

        vm.prank(alice);
        vm.expectRevert("Auction ended");
        auction.bid{value: 1 ether}();
    }

    function test_auctionExtension() public {
        vm.warp(startTime + 1 hours - 3 minutes);

        vm.expectEmit(true, true, false, true);
        emit AuctionExtended(block.timestamp + 5 minutes);

        vm.prank(alice);
        auction.bid{value: 1 ether}();

        assertEq(auction.auctionEndTime(), block.timestamp + 5 minutes);
    }
}
