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

  address owner;
  mapping(string => Order) orders;

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
}