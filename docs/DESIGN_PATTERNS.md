# Design Patterns

- Factory Pattern: `ResourceAMMFactory` and `GameModuleFactory` deploy modules through CREATE and CREATE2.
- Proxy / UUPS: `CraftingManager` is upgradeable and `CraftingManagerV2` documents the V1 to V2 path.
- Checks-Effects-Interactions: `ResourcePair` and `ItemRentalVault` update accounting before outward transfers.
- ReentrancyGuard: AMM, loot, crafting, and rental flows protect stateful write functions.
- AccessControl: ERC-1155 mint/burn, crafting config, loot config, and pausing are role-gated.
- Timelock: DAO actions are delayed by `BlockCraftTimelock`.
- Oracle Adapter: `CraftPriceOracle` isolates Chainlink feed logic and stale checks.
- State Machine: rental positions move through `Available`, `Rented`, and `Returned`.
- Pausable: critical modules can be stopped during incidents.
- Pull-over-push: rental lenders claim accrued fees instead of receiving forced transfers.
