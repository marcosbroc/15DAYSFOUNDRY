// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract SimpleAuction {
    address public owner;
    address public highestBidder;
    uint256 public highestBid;
    uint256 public auctionEndTime;
    bool public ended;

    event BidPlaced(address bidder, uint256 amount);
    event AuctionExtended(uint256 newEndTime);
    event AuctionEnded(address indexed winner, uint256 amount);

    constructor(uint256 duration) {
        owner = msg.sender;
        auctionEndTime = block.timestamp + duration;
    }

    function bid() public payable {
        require(block.timestamp < auctionEndTime, "Auction ended");
        require(msg.value > highestBid, "Bid too low");

        highestBidder = msg.sender;
        highestBid = msg.value;

        if (auctionEndTime - block.timestamp < 300) {
            auctionEndTime = block.timestamp + 300;
            emit AuctionExtended(auctionEndTime);
        }

        emit BidPlaced(msg.sender, msg.value);
    }

    function endAuction() public {
        require(block.timestamp >= auctionEndTime, "Auction still active");
        require(!ended, "Already ended");
        ended = true;
        emit AuctionEnded(highestBidder, highestBid);
    }

    function timeLeft() public view returns (uint256) {
        if (block.timestamp >= auctionEndTime) return 0;
        return auctionEndTime - block.timestamp;
    }
}
