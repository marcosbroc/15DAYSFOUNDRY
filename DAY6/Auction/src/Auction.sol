// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Auction {
    address public owner;
    uint256 public duration;
    AuctionedItem[] auctionedItems;

    // Events
    event itemAdded(uint128 itemId, uint128 startingPrice, uint256 timeLeft);
    event newSuccessfulBid(uint128 itemId, address bidder, uint128 bidPrice, uint256 timeLeft);
    event itemGone(uint128 indexed itemId, address indexed winner, uint128 indexed finalPrice);
    event timeExtended(uint128 itemId, uint256 newTimeLeft);

    // Only the owner can add items and end auction
    constructor(uint256 _duration) {
        owner = msg.sender;
        duration = _duration;
    }

    struct AuctionedItem {
        string description;
        uint128 startingPrice;
        uint256 auctionStart;
        uint256 auctionEnd;
        address highestBidder;
        uint128 highestBid;
        bool isAvailable;
    }

    modifier OnlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function bid(uint128 _index, uint128 _amount) public {
        // We retrieve the item
        require(_index < auctionedItems.length, "Item not found");
        AuctionedItem memory _item = auctionedItems[_index];

        // We check conditions
        require(_item.isAvailable, "Item already gone");
        require(block.timestamp < _item.auctionEnd, "Auction ended for this object");
        if (_item.highestBid == 0) {
            require(_amount >= _item.startingPrice, "Bid must reach at least the starting price");
        } else {
            require(_amount > _item.highestBid, "Current bid is not beating highest bid");
        }

        // Set new best bid (only now we use storage)
        AuctionedItem storage itemStored = auctionedItems[_index];
        itemStored.highestBid = _amount;
        itemStored.highestBidder = msg.sender;
        emit newSuccessfulBid(_index, msg.sender, _amount, itemStored.auctionEnd - block.timestamp);

        // Extend the item's bid for 5 more minutes if it's less than 5 minutes to go
        if (itemStored.auctionEnd - block.timestamp < 300) {
            itemStored.auctionEnd += 300;
            emit timeExtended(_index, itemStored.auctionEnd - block.timestamp);
        }
    }

    // Not gas efficient, but we want to keep it simple
    function endAuction() public OnlyOwner {
        for (uint128 i = 0; i < auctionedItems.length; i++) {
            AuctionedItem storage itemStored = auctionedItems[i];
            if (itemStored.isAvailable && block.timestamp >= itemStored.auctionEnd) {
                // Not available anymore
                itemStored.isAvailable = false;

                // Only if there is a highest bidder, we emit the event
                if (itemStored.highestBidder != address(0)) {
                    emit itemGone(i, itemStored.highestBidder, itemStored.highestBid);
                }
            }
        }
    }

    function getItem(uint128 _index) public view returns (AuctionedItem memory) {
        require(_index < auctionedItems.length, "Item not found");
        return auctionedItems[_index];
    }

    function setItem(string memory _description, uint128 _startingPrice) public OnlyOwner {
        require(_startingPrice > 0, "Starting price should be greater than zero");
        AuctionedItem memory _item = AuctionedItem({
            description: _description,
            startingPrice: _startingPrice,
            auctionStart: block.timestamp,
            auctionEnd: block.timestamp + duration,
            highestBidder: address(0),
            highestBid: 0,
            isAvailable: true
        });
        auctionedItems.push(_item);
    }
}
