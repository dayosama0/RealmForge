// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {CraftingManager} from "./CraftingManager.sol";

contract CraftingManagerV2 is CraftingManager {
    function batchCraft(uint256[] calldata itemIds) external {
        for (uint256 i = 0; i < itemIds.length; i++) {
            craft(itemIds[i]);
        }
    }

    function version() external pure returns (string memory) {
        return "2.0.0";
    }
}
