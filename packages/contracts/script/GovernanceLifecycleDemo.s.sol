// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {BlockCraftGovernor} from "../src/governance/BlockCraftGovernor.sol";

contract GovernanceLifecycleDemo is Script {
    function proposeOnly(
        BlockCraftGovernor governor,
        address target,
        bytes calldata callData,
        string calldata description
    ) external returns (uint256 proposalId) {
        address[] memory targets = new address[](1);
        uint256[] memory values = new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);
        targets[0] = target;
        calldatas[0] = callData;
        vm.startBroadcast();
        proposalId = governor.propose(targets, values, calldatas, description);
        vm.stopBroadcast();
    }
}
