// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Orders {
  enum Status {Created, Paid, Delivered, Refunded}

  struct Order {
    string id;
    uint256 totalPrice;
    uint256 deliveryDate;
    Status status;
    uint256 createdDate;
    uint256 deliveredDate;
  }

  struct Payment {
    string id;
    address payable buyeraddress;
    uint256 paidDate;
    uint256 refundedDate;
  }

  event OrderPaid (string id, address paidAddress, uint256 paidAmount, uint256 date);
  event OrderDelivered(string id, uint256 date);
  event OrderRefunded(string id, uint256 date);

  address owner;
  mapping(string => Order) orders;
  mapping(string => Payment) payments;

  modifier onlyOwner {
    require(msg.sender == owner, "The sender is not authorized to perform transaction");
    _;
  }

  constructor() {
    owner = msg.sender;
  }

  function add(string memory id, uint256 totalPrice, uint256 deliveryDate) public onlyOwner {
    orders[id] = Order(id, totalPrice, deliveryDate, Status.Created, block.timestamp, 0);
  }

  function get(string memory id) public view returns (uint8 status, uint256 createdDate, uint256 deliveryDate, uint256 deliveredDate ) {
    Order memory order = orders[id];
    require(order.createdDate > 0, "Order is not found!");
    return (
      uint8(order.status),
      order.createdDate,
      order.deliveryDate,
      order.deliveredDate
    );
  }

  function pay(string memory id) public payable {
    Order storage order = orders[id];

    require(order.createdDate > 0, "Order is not found");

    Payment storage payment = payments[id];

    require(payment.paidDate == 0, "The order has been paid");

    require(msg.value == order.totalPrice, "The order price does not match the value of the transaction");
    
    order.status = Status.Paid;

    payments[id] = Payment(id, payable(msg.sender), getTime(), 0);

    emit OrderPaid(id, msg.sender, msg.value, block.timestamp);
  }

  function deliver(string memory id) public onlyOwner {
    Order storage order = orders[id];

    require(order.createdDate > 0, "Order is not found");
    require(order.deliveredDate == 0, "The order has been delivered");

    order.status = Status.Delivered;
    order.deliveredDate = block.timestamp;

    emit OrderDelivered(id, order.deliveredDate);
  }

  function refund(string memory id) public {
    Order storage order = orders[id];
    require(order.createdDate > 0, "Order is not found");

    Payment storage payment = payments[id];
    require(payment.paidDate > 0, "The order has not been paid for");
    require(order.deliveredDate == 0, "The order has been delivered");
    require(payment.refundedDate == 0, "The order has been refunded");

    require(payment.buyeraddress == msg.sender, "The buyer address does not match the address of the transaction");

    require(uint256(getTime()) > order.deliveryDate, "The delivery date is not over yet");

    payment.buyeraddress.transfer(order.totalPrice);
    order.status = Status.Refunded;

    payment.refundedDate = getTime();

     emit OrderRefunded(id, payment.refundedDate);
  }

  function getTime() virtual internal view returns (uint256) {
    return block.timestamp;
  }
}