// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {CraftToken} from "../../src/tokens/CraftToken.sol";

contract GovernanceVotingPowerFuzzTest is Test {
    CraftToken craft;
    address voter = address(0x1001);

    function setUp() public {
        craft = new CraftToken(address(this), 1_000_000 ether);
    }

    function testFuzzVotingPowerAfterDelegate(uint96 amount) public {
        amount = uint96(bound(amount, 1, 100_000 ether));
        craft.transfer(voter, amount);
        vm.prank(voter);
        craft.delegate(voter);
        assertEq(craft.getVotes(voter), amount);
    }

    function testFuzzOwnerMintVotingPower(uint96 amount) public {
        amount = uint96(bound(amount, 1, 100_000 ether));
        craft.mint(voter, amount);
        vm.prank(voter);
        craft.delegate(voter);
        assertEq(craft.getVotes(voter), amount);
    }
}
