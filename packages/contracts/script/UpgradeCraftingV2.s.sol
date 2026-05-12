// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {CraftingManager} from "../src/crafting/CraftingManager.sol";
import {CraftingManagerV2} from "../src/crafting/CraftingManagerV2.sol";

contract UpgradeCraftingV2 is Script {
    function run(address proxy) external {
        vm.startBroadcast();
        CraftingManagerV2 implementation = new CraftingManagerV2();
        CraftingManager(proxy).upgradeToAndCall(address(implementation), "");
        vm.stopBroadcast();
    }
}
