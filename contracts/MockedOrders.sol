// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./Orders.sol";

contract MockedOrders is Orders {
  uint256 fakeTimestamp;

  function getTime() override internal view returns (uint256) {
    return fakeTimestamp;
  }

  function mockTimestamp(uint256 timestamp) public {
    fakeTimestamp = timestamp;
  }
}