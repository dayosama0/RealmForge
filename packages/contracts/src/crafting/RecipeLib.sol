// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library RecipeLib {
    struct Ingredient {
        uint256 itemId;
        uint256 amount;
    }

    struct Recipe {
        uint256 outputItemId;
        uint256 outputAmount;
        Ingredient[] ingredients;
        bool exists;
    }
}
