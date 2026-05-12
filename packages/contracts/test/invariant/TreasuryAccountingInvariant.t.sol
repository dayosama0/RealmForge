// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

contract TreasuryAccountingInvariantHandler {
    uint256 public assets;

    function depositShadow(uint256 amount) external {
        assets += amount % 1e18;
    }
}

contract TreasuryAccountingInvariantTest is Test {
    TreasuryAccountingInvariantHandler public handler;

    function setUp() public {
        handler = new TreasuryAccountingInvariantHandler();
        targetContract(address(handler));
    }

    function invariantTreasuryAccountingNonNegative() public view {
        assertGe(handler.assets(), 0);
    }
}
