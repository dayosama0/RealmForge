// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library Events {
    event Crafted(address indexed player, uint256 indexed itemId, uint256 amount);
    event RecipeUpdated(uint256 indexed itemId);
    event PairCreated(address indexed pair, uint256 indexed token0Id, uint256 indexed token1Id, bool deterministic);
    event Swap(address indexed player, uint256 indexed tokenInId, uint256 indexed tokenOutId, uint256 amountIn, uint256 amountOut);
    event LiquidityAdded(address indexed provider, uint256 amount0, uint256 amount1, uint256 lpMinted);
    event LiquidityRemoved(address indexed provider, uint256 amount0, uint256 amount1, uint256 lpBurned);
    event LootRequested(address indexed player, uint256 indexed requestId);
    event LootFulfilled(address indexed player, uint256 indexed requestId, uint256 rewardItemId, uint256 rewardAmount);
    event RentalListed(uint256 indexed positionId, address indexed lender, uint256 indexed itemId, uint256 price, uint256 duration);
    event ItemRented(uint256 indexed positionId, address indexed renter, uint256 expiresAt);
    event ItemReturned(uint256 indexed positionId);
}
