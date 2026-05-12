// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {ERC1155Holder} from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import {BlockCraftItems} from "../../src/tokens/BlockCraftItems.sol";
import {ResourceAMMFactory} from "../../src/amm/ResourceAMMFactory.sol";
import {ResourcePair} from "../../src/amm/ResourcePair.sol";

contract AMMSwapFuzzTest is Test, ERC1155Holder {
    BlockCraftItems items;
    ResourcePair pair;
    address player = address(0xABCD);

    function setUp() public {
        items = new BlockCraftItems("", address(this));
        ResourceAMMFactory factory = new ResourceAMMFactory(address(items), address(this));
        pair = ResourcePair(factory.createPair(items.WOOD(), items.STONE()));
        items.mint(address(this), items.WOOD(), 1_000_000, "");
        items.mint(address(this), items.STONE(), 1_000_000, "");
        items.setApprovalForAll(address(pair), true);
        items.mint(player, items.WOOD(), 1_000_000, "");
        items.mint(player, items.STONE(), 1_000_000, "");
        vm.startPrank(player);
        items.setApprovalForAll(address(pair), true);
        pair.addLiquidity(500_000, 500_000, 1);
        vm.stopPrank();
    }

    function testFuzzSwapWood(uint96 amount) public {
        amount = uint96(bound(amount, 100, 10_000));
        uint256 out = pair.swapExactInput(items.WOOD(), amount, 1);
        assertGt(out, 0);
    }

    function testFuzzSwapStone(uint96 amount) public {
        amount = uint96(bound(amount, 100, 10_000));
        uint256 out = pair.swapExactInput(items.STONE(), amount, 1);
        assertGt(out, 0);
    }
}
