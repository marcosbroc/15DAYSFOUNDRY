// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Version 2: Gas-Optimized Store
contract OptimizedStore {
    struct Item {
        uint128 price; // ✅ Packed: 16 bytes
        uint128 quantity; // ✅ Packed: 16 bytes (same slot as price)
        bool available; // ✅ Packed: 1 byte (next slot, room for more data)
    }
    // Total: 2 storage slots instead of 3 = saves ~20,000 gas per item

    // Pack multiple values in single storage slot to save gas
    struct PackedData {
        uint128 totalRevenue; // Usually sufficient for revenue (340 trillion ETH max)
        uint128 nextItemId; // Pack with revenue - most contracts won't have 340 trillion items
    }

    mapping(uint256 => Item) public items;
    mapping(bytes32 => string) private itemNames; // ✅ Separate mapping for strings keeps structs lean
    mapping(address => uint256[]) public userPurchases;

    PackedData public packedData;
    address public immutable owner; // ✅ Immutable: 200 gas → 3 gas per read

    // ✅ More efficient events - removed string from event (strings are expensive to emit)
    event ItemAdded(uint256 indexed itemId, uint256 price);
    event ItemPurchased(uint256 indexed itemId, address indexed buyer, uint256 quantity);

    // ✅ Custom errors: ~200 gas vs ~24,000 gas for require strings
    error NotOwner();
    error ItemNotAvailable();
    error InsufficientQuantity();
    error InsufficientPayment();

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner(); // ✅ Custom error vs require
        _;
    }

    // ✅ Using calldata instead of memory for external function parameters saves gas
    function addItem(string calldata name, uint128 price, uint128 quantity) external onlyOwner {
        uint256 itemId = packedData.nextItemId; // ✅ Cache storage read

        items[itemId] = Item({price: price, quantity: quantity, available: true});

        // ✅ Store name separately to avoid struct bloat and gas costs
        itemNames[keccak256(abi.encodePacked(itemId))] = name;

        emit ItemAdded(itemId, price);

        // ✅ Update packed data in one operation, use unchecked for impossible overflow
        unchecked {
            packedData.nextItemId = uint128(itemId + 1);
        }
    }

    function purchaseItem(uint256 itemId, uint128 quantity) external payable {
        Item storage item = items[itemId]; // ✅ Single storage pointer, multiple uses

        // ✅ Custom errors instead of require strings
        if (!item.available) revert ItemNotAvailable();
        if (item.quantity < quantity) revert InsufficientQuantity();

        uint256 totalCost = uint256(item.price) * quantity;
        if (msg.value < totalCost) revert InsufficientPayment();

        // ✅ Update item data with unchecked math (underflow impossible due to check above)
        unchecked {
            item.quantity -= quantity;
        }
        if (item.quantity == 0) {
            item.available = false;
        }

        // Update user purchases and revenue
        userPurchases[msg.sender].push(itemId);

        // ✅ Unchecked math - overflow extremely unlikely with reasonable values
        unchecked {
            packedData.totalRevenue += uint128(msg.value);
        }

        emit ItemPurchased(itemId, msg.sender, quantity);

        // ✅ Refund excess payment - unchecked safe due to earlier check
        unchecked {
            if (msg.value > totalCost) {
                payable(msg.sender).transfer(msg.value - totalCost);
            }
        }
    }

    function getItemName(uint256 itemId) external view returns (string memory) {
        return itemNames[keccak256(abi.encodePacked(itemId))];
    }

    function getItemDetails(uint256 itemId) external view returns (uint128 price, uint128 quantity, bool available) {
        Item memory item = items[itemId];
        return (item.price, item.quantity, item.available);
    }

    function getTotalRevenue() external view returns (uint256) {
        return packedData.totalRevenue;
    }

    function getNextItemId() external view returns (uint256) {
        return packedData.nextItemId;
    }
}
