// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

contract GovernanceInvariantHandler {
    uint256 public minDelay = 2 days;

    function noop(uint256) external {}
}

contract GovernanceInvariantTest is Test {
    GovernanceInvariantHandler public handler;

    function setUp() public {
        handler = new GovernanceInvariantHandler();
        targetContract(address(handler));
    }

    function invariantGovernorUsesTimelockDelay() public view {
        assertEq(handler.minDelay(), 2 days);
    }
}
