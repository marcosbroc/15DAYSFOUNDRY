// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Version 1: Unoptimized Store
contract SimpleStore {
    struct Item {
        string name;
        uint256 price;
        uint256 quantity;
        bool available;
    }

    mapping(uint256 => Item) public items;
    mapping(address => uint256[]) public userPurchases;
    uint256 public nextItemId;
    address public owner;
    uint256 public totalRevenue;

    event ItemAdded(uint256 indexed itemId, string name, uint256 price);
    event ItemPurchased(uint256 indexed itemId, address indexed buyer, uint256 quantity);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    function addItem(string memory name, uint256 price, uint256 quantity) external onlyOwner {
        items[nextItemId] = Item({name: name, price: price, quantity: quantity, available: true});

        emit ItemAdded(nextItemId, name, price);
        nextItemId++;
    }

    function purchaseItem(uint256 itemId, uint256 quantity) external payable {
        Item storage item = items[itemId];

        require(item.available, "Item not available");
        require(item.quantity >= quantity, "Insufficient quantity");
        require(msg.value >= item.price * quantity, "Insufficient payment");

        item.quantity -= quantity;
        if (item.quantity == 0) {
            item.available = false;
        }

        userPurchases[msg.sender].push(itemId);
        totalRevenue += msg.value;

        emit ItemPurchased(itemId, msg.sender, quantity);

        // Refund excess payment
        if (msg.value > item.price * quantity) {
            payable(msg.sender).transfer(msg.value - (item.price * quantity));
        }
    }

    function getItemDetails(uint256 itemId) external view returns (Item memory) {
        return items[itemId];
    }

    function getUserPurchases(address user) external view returns (uint256[] memory) {
        return userPurchases[user];
    }
}
