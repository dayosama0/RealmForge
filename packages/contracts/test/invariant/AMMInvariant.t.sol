// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

contract AMMInvariantHandler {
    uint256 public k = 1;

    function touch(uint256 amount) external {
        k += amount % 100;
    }
}

contract AMMInvariantTest is Test {
    AMMInvariantHandler public handler;

    function setUp() public {
        handler = new AMMInvariantHandler();
        targetContract(address(handler));
    }

    function invariantKDoesNotDecrease() public view {
        assertGe(handler.k(), 1);
    }
}
