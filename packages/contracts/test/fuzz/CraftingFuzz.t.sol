// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {BlockCraftItems} from "../../src/tokens/BlockCraftItems.sol";
import {CraftingManager} from "../../src/crafting/CraftingManager.sol";

contract CraftingFuzzTest is Test {
    BlockCraftItems items;
    CraftingManager crafting;
    address player = address(0xB0B);

    function setUp() public {
        items = new BlockCraftItems("", address(this));
        CraftingManager impl = new CraftingManager();
        ERC1967Proxy proxy = new ERC1967Proxy(address(impl), abi.encodeCall(CraftingManager.initialize, (address(items), address(this))));
        crafting = CraftingManager(address(proxy));
        items.grantRole(items.MINTER_ROLE(), address(crafting));
        items.grantRole(items.BURNER_ROLE(), address(crafting));
        items.mint(player, items.DIAMOND(), 1000, "");
        items.mint(player, items.WOOD(), 1000, "");
    }

    function testFuzzCraftManyDiamondPickaxes(uint8 count) public {
        count = uint8(bound(count, 1, 20));
        vm.startPrank(player);
        items.setApprovalForAll(address(crafting), true);
        for (uint256 i = 0; i < count; i++) crafting.craft(items.DIAMOND_PICKAXE());
        vm.stopPrank();
        assertEq(items.balanceOf(player, items.DIAMOND_PICKAXE()), count);
    }

    function testFuzzCustomRecipeCost(uint8 amount) public {
        amount = uint8(bound(amount, 1, 20));
        uint256[] memory ids = new uint256[](1);
        uint256[] memory costs = new uint256[](1);
        ids[0] = items.WOOD();
        costs[0] = amount;
        crafting.setRecipe(items.WOODEN_PICKAXE(), ids, costs);
        vm.startPrank(player);
        items.setApprovalForAll(address(crafting), true);
        crafting.craft(items.WOODEN_PICKAXE());
        vm.stopPrank();
        assertEq(items.balanceOf(player, items.WOODEN_PICKAXE()), 1);
    }
}
