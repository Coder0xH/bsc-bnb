// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/BscOrder.sol";

// Ownable errors
error OwnableUnauthorizedAccount(address account);

contract BscOrderPaymentTest is Test {
    BscOrder public payment;
    address public owner;
    address public receiver;
    address public user;

    event PaymentMade(string orderId, address user, uint256 amount, uint256 timestamp);
    event ReceiverUpdated(address oldReceiver, address newReceiver);

    function setUp() public {
        // Setup accounts
        owner = makeAddr("owner");
        receiver = makeAddr("receiver");
        user = makeAddr("user");

        // Deploy payment contract
        vm.prank(owner);
        payment = new BscOrder(receiver, owner);

        // Give user some BNB
        vm.deal(user, 100 ether);
    }

    function test_InitialState() public view {
        assertEq(payment.receiver(), receiver);
        assertEq(payment.owner(), owner);
    }

    function test_Pay() public {
        uint256 amount = 1 ether;
        string memory orderId = "ORDER_001";

        uint256 receiverInitialBalance = receiver.balance;

        // Make payment
        vm.prank(user);
        payment.pay{value: amount}(orderId);

        // Verify receiver balance
        assertEq(receiver.balance, receiverInitialBalance + amount);
    }

    function test_SetReceiver() public {
        address newReceiver = makeAddr("newReceiver");

        // Only owner can set receiver
        vm.prank(owner);

        // Expect ReceiverUpdated event
        vm.expectEmit(true, true, true, true);
        emit ReceiverUpdated(receiver, newReceiver);

        payment.setReceiver(newReceiver);
        assertEq(payment.receiver(), newReceiver);
    }

    function test_RevertWhen_PayWithInvalidOrderId() public {
        vm.prank(user);
        vm.expectRevert("Invalid order ID");
        payment.pay{value: 1 ether}("");
    }

    function test_RevertWhen_PayWithZeroAmount() public {
        vm.prank(user);
        vm.expectRevert("Amount must be greater than 0");
        payment.pay{value: 0}("ORDER_001");
    }

    function test_RevertWhen_SetReceiverNonOwner() public {
        vm.prank(user);
        vm.expectRevert(abi.encodeWithSelector(OwnableUnauthorizedAccount.selector, user));
        payment.setReceiver(makeAddr("newReceiver"));
    }

    function test_RevertWhen_SetReceiverZeroAddress() public {
        vm.prank(owner);
        vm.expectRevert("Invalid receiver address");
        payment.setReceiver(address(0));
    }
}
