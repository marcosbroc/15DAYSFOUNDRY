// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract SimpleShop {
    uint256 public nextItemId;

    struct Item {
        string name;
        uint256 price;
        uint256 quantity;
        bool available;
    }

    mapping(uint256 => Item) public items;
    mapping(address => uint256[]) public userPurchase;

    address public owner;
    uint256 public totalRevenue;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    // Try calldata instead of memory for _name
    function addItem(
        string memory _name,
        uint256 _price,
        uint256 _quantity
    ) public onlyOwner {
        items[nextItemId] = Item({
            name: _name,
            price: _price,
            quantity: _quantity,
            available: true
        });

        nextItemId++;
    }

    function purchaseItem(uint256 itemId, uint256 quantity) public payable {
        Item storage selectedItem = items[itemId];
        require(selectedItem.available, "Item not available");
        require(
            selectedItem.quantity >= quantity,
            "Not enough items available"
        );
        require(msg.value >= selectedItem.price * quantity, "Pay more");

        selectedItem.quantity -= quantity;

        if (selectedItem.quantity == 0) {
            selectedItem.available = false;
        }

        userPurchase[msg.sender].push(itemId);

        totalRevenue += msg.value;

        if (msg.value >= selectedItem.price * quantity) {
            payable(msg.sender).transfer(
                msg.value - (selectedItem.price * quantity)
            );
        }
    }

    function getItemDetails(uint256 itemId) public view returns (Item memory) {
        return items[itemId];
    }

    function getUserPurchase(
        address user
    ) public view returns (uint256[] memory) {
        return userPurchase[user];
    }
}
