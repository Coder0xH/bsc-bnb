// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

contract BscOrder is Ownable, ReentrancyGuard {
    address public receiver;

    event PaymentMade(string orderId, address user, uint256 amount, uint256 timestamp);
    event ReceiverUpdated(address oldReceiver, address newReceiver);

    constructor(address _receiver, address initialOwner) Ownable(initialOwner) {
        require(_receiver != address(0), "Invalid receiver address");
        receiver = _receiver;
    }

    /**
     * @notice Process payment with order ID and amount in BNB
     * @param orderId Unique identifier for the order
     */
    function pay(string memory orderId) external payable nonReentrant {
        require(bytes(orderId).length > 0, "Invalid order ID");
        require(msg.value > 0, "Amount must be greater than 0");
        
        (bool success, ) = receiver.call{value: msg.value}("");
        require(success, "Transfer failed");

        emit PaymentMade(orderId, msg.sender, msg.value, block.timestamp);
    }

    /**
     * @notice Update receiver address, only callable by owner
     * @param newReceiver New address to receive payments
     */
    function setReceiver(address newReceiver) external onlyOwner {
        require(newReceiver != address(0), "Invalid receiver address");
        address oldReceiver = receiver;
        receiver = newReceiver;
        emit ReceiverUpdated(oldReceiver, newReceiver);
    }
}
