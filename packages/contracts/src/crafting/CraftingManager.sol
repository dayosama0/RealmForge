// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {BlockCraftItems} from "../tokens/BlockCraftItems.sol";
import {RecipeLib} from "./RecipeLib.sol";
import {Events} from "../utils/Events.sol";
import {Errors} from "../utils/Errors.sol";

contract CraftingManager is
    Initializable,
    AccessControlUpgradeable,
    UUPSUpgradeable,
    PausableUpgradeable,
    ReentrancyGuard
{
    using RecipeLib for RecipeLib.Recipe;

    bytes32 public constant CONFIG_ROLE = keccak256("CONFIG_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    BlockCraftItems public items;
    mapping(uint256 => RecipeLib.Recipe) internal recipes;

    function initialize(address itemAddress, address admin) public initializer {
        if (itemAddress == address(0) || admin == address(0)) revert Errors.ZeroAddress();
        __AccessControl_init();
        __Pausable_init();

        items = BlockCraftItems(itemAddress);
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(CONFIG_ROLE, admin);
        _grantRole(UPGRADER_ROLE, admin);
        _grantRole(PAUSER_ROLE, admin);

        _setRecipe(101, _ids(3, 1, 0), _amounts(3, 2, 0));
        _setRecipe(102, _ids(5, 1, 0), _amounts(3, 2, 0));
        _setRecipe(103, _ids(5, 1, 0), _amounts(2, 1, 0));
        _setRecipe(
            200,
            _ids(103, 104, 7),
            _amounts(1, 1, 5)
        );
    }

    function craft(uint256 itemId) public virtual nonReentrant whenNotPaused {
        RecipeLib.Recipe storage recipe = recipes[itemId];
        if (!recipe.exists) revert Errors.RecipeMissing();

        uint256 len = recipe.ingredients.length;
        uint256[] memory ids = new uint256[](len);
        uint256[] memory amounts = new uint256[](len);
        for (uint256 i = 0; i < len; i++) {
            ids[i] = recipe.ingredients[i].itemId;
            amounts[i] = recipe.ingredients[i].amount;
        }
        items.burnBatchFrom(msg.sender, ids, amounts);
        items.mint(msg.sender, recipe.outputItemId, recipe.outputAmount, "");
        emit Events.Crafted(msg.sender, itemId, recipe.outputAmount);
    }

    function setRecipe(uint256 outputItemId, uint256[] calldata ingredientIds, uint256[] calldata amounts)
        external
        onlyRole(CONFIG_ROLE)
    {
        if (ingredientIds.length != amounts.length || ingredientIds.length == 0) revert Errors.InvalidAmount();
        delete recipes[outputItemId].ingredients;
        recipes[outputItemId].outputItemId = outputItemId;
        recipes[outputItemId].outputAmount = 1;
        recipes[outputItemId].exists = true;
        for (uint256 i = 0; i < ingredientIds.length; i++) {
            recipes[outputItemId].ingredients.push(RecipeLib.Ingredient(ingredientIds[i], amounts[i]));
        }
        emit Events.RecipeUpdated(outputItemId);
    }

    function getRecipe(uint256 itemId) external view returns (RecipeLib.Ingredient[] memory ingredients, uint256 outputAmount) {
        RecipeLib.Recipe storage recipe = recipes[itemId];
        return (recipe.ingredients, recipe.outputAmount);
    }

    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function _authorizeUpgrade(address) internal override onlyRole(UPGRADER_ROLE) {}

    function _setRecipe(uint256 outputItemId, uint256[3] memory ingredientIds, uint256[3] memory amounts) internal {
        recipes[outputItemId].outputItemId = outputItemId;
        recipes[outputItemId].outputAmount = 1;
        recipes[outputItemId].exists = true;
        for (uint256 i = 0; i < 3; i++) {
            if (ingredientIds[i] != 0) recipes[outputItemId].ingredients.push(RecipeLib.Ingredient(ingredientIds[i], amounts[i]));
        }
    }

    function _ids(uint256 a, uint256 b, uint256 c) private pure returns (uint256[3] memory out) {
        out = [a, b, c];
    }

    function _amounts(uint256 a, uint256 b, uint256 c) private pure returns (uint256[3] memory out) {
        out = [a, b, c];
    }
}
