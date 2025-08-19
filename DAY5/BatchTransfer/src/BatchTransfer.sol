// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract BatchTransfer {
    struct Transfer {
        address recipient;
        bytes32 description;
        uint128 amount;
        bool isProcessed;
    }

    constructor() {
        owner = msg.sender;
    }

    Transfer[] public transfers;
    uint128 public nextTransferId;
    address public immutable owner;

    event TransferAdded(uint128 indexed transferId, address indexed recipient, uint128 amount);
    event TransferExecuted(uint128 indexed transferId, address indexed recipient, uint128 amount);

    error NotOwner();
    error InvalidRecipientAddress();
    error AmountMustBeGreaterThanZero();
    error TransferDoesNotExist();
    error NotEnoughBalance();
    error TransferAlreadyProcessed();

    modifier OwnerOnly() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    function addTransfer(address recipient, bytes32 description, uint128 amount) public OwnerOnly {
        if (recipient == address(0)) revert InvalidRecipientAddress();
        if (amount == 0) revert AmountMustBeGreaterThanZero();
        transfers.push(Transfer({recipient: recipient, description: description, amount: amount, isProcessed: false}));
        emit TransferAdded(nextTransferId, recipient, amount);
        unchecked {
            nextTransferId++;
        }
    }

    function getTransfer(uint128 _requestedId) public view returns (Transfer memory) {
        if (_requestedId >= nextTransferId) revert TransferDoesNotExist();
        return transfers[_requestedId];
    }

    function processTransfer() public OwnerOnly {
        for (uint128 i = 0; i < transfers.length; i++) {
            // Ensure the contract has enough balance to process the transfer
            Transfer memory currentTransfer = transfers[i];
            if (address(this).balance < currentTransfer.amount) revert NotEnoughBalance();
            address payable _recipient = payable(currentTransfer.recipient);

            // Transfer is not processed yet
            if (currentTransfer.isProcessed) revert TransferAlreadyProcessed();
            _recipient.transfer(currentTransfer.amount);

            // Mark the transfer as processed and inform the listeners
            transfers[i].isProcessed = true;
            emit TransferExecuted(i, currentTransfer.recipient, currentTransfer.amount);
        }
    }
}
