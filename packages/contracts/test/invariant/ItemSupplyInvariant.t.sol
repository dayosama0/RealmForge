// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

contract ItemSupplyInvariantHandler {
    uint256 public totalSupplyShadow;

    function mintShadow(uint256 amount) external {
        totalSupplyShadow += amount % 1e18;
    }
}

contract ItemSupplyInvariantTest is Test {
    ItemSupplyInvariantHandler public handler;

    function setUp() public {
        handler = new ItemSupplyInvariantHandler();
        targetContract(address(handler));
    }

    function invariantNoNegativeSupply() public view {
        assertGe(handler.totalSupplyShadow(), 0);
    }
}
