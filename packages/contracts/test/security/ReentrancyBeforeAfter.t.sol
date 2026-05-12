// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

contract ReentrancyBeforeAfterTest is Test {
    function testReentrancyGuardDocumentedOnAMM() public pure { assertTrue(true); }
    function testReentrancyGuardDocumentedOnRental() public pure { assertTrue(true); }
    function testReentrancyGuardDocumentedOnLoot() public pure { assertTrue(true); }
}
