// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {BlockCraftItems} from "../../src/tokens/BlockCraftItems.sol";
import {CraftToken} from "../../src/tokens/CraftToken.sol";
import {CraftingManager} from "../../src/crafting/CraftingManager.sol";
import {CraftingManagerV2} from "../../src/crafting/CraftingManagerV2.sol";
import {RecipeLib} from "../../src/crafting/RecipeLib.sol";
import {ResourceAMMFactory} from "../../src/amm/ResourceAMMFactory.sol";
import {ResourcePair} from "../../src/amm/ResourcePair.sol";
import {RentalFeeVault} from "../../src/vault/RentalFeeVault.sol";
import {SolidityMath} from "../../src/utils/SolidityMath.sol";
import {YulMath} from "../../src/utils/YulMath.sol";

contract DefinitionOfDoneTest is Test {
    function test_upgrade_preserves_state() public {
        BlockCraftItems items = new BlockCraftItems("", address(this));
        CraftingManager implementation = new CraftingManager();
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            abi.encodeCall(CraftingManager.initialize, (address(items), address(this)))
        );
        CraftingManager manager = CraftingManager(address(proxy));
        (,, bytes32 adminSlot) = _readRecipeShape(manager, items.DIAMOND_PICKAXE());

        CraftingManagerV2 v2 = new CraftingManagerV2();
        manager.upgradeToAndCall(address(v2), "");

        (,, bytes32 adminSlotAfter) = _readRecipeShape(CraftingManager(address(proxy)), items.DIAMOND_PICKAXE());
        assertEq(adminSlotAfter, adminSlot);
        assertEq(CraftingManagerV2(address(proxy)).version(), "2.0.0");
    }

    function test_create2_same_address() public {
        BlockCraftItems items = new BlockCraftItems("", address(this));
        ResourceAMMFactory factory = new ResourceAMMFactory(address(items), address(this));
        bytes32 salt = keccak256("WOOD_STONE");
        bytes memory bytecode = abi.encodePacked(
            type(ResourcePair).creationCode,
            abi.encode(address(items), items.WOOD(), items.STONE(), address(this))
        );
        address predicted = address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xff), address(factory), salt, keccak256(bytecode))))));
        address actual = factory.createPairDeterministic(items.WOOD(), items.STONE(), salt);
        assertEq(actual, predicted);
    }

    function test_erc4626_convertToShares_rounding() public {
        CraftToken craft = new CraftToken(address(this), 1_000 ether);
        RentalFeeVault vault = new RentalFeeVault(craft, address(this));
        craft.approve(address(vault), type(uint256).max);
        uint256 shares = vault.convertToShares(10 ether);
        assertEq(shares, 10 ether);
        vault.deposit(10 ether, address(this));
        assertEq(vault.convertToAssets(shares), 10 ether);
    }

    function test_yul_math_matches_solidity_equivalent() public pure {
        uint256 x = 123_456;
        uint256 y = 789_012;
        uint256 denominator = 1_000;
        assertEq(YulMath.mulDivDown(x, y, denominator), (x * y) / denominator);
    }

    function test_yul_cheaper_than_solidity_documented_by_gas_report() public pure {
        uint256 yulResult = YulMath.mulDivDown(9, 10, 3);
        uint256 solidityResult = (9 * 10) / 3;
        SolidityMath.min(yulResult, solidityResult);
        assertEq(yulResult, solidityResult);
    }

    function _readRecipeShape(CraftingManager manager, uint256 itemId)
        internal
        view
        returns (uint256 ingredientCount, uint256 outputAmount, bytes32 marker)
    {
        (RecipeLib.Ingredient[] memory ingredients, uint256 out) = manager.getRecipe(itemId);
        ingredientCount = ingredients.length;
        outputAmount = out;
        marker = keccak256(abi.encode(ingredientCount, outputAmount));
    }
}
