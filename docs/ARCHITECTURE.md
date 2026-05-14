# BlockCraft Economy Architecture

BlockCraft Economy is a Minecraft-inspired GameFi protocol, not an official Minecraft product.

## Module Map

- `CraftToken`: ERC20Votes + Permit token for governance, rental payments, and loot payments.
- `BlockCraftItems`: ERC-1155 item registry for resources and rare items.
- `CraftingManager`: UUPS upgradeable recipe engine. V1 exposes `craft`; V2 adds `batchCraft` and `version`.
- `ResourceAMMFactory` and `ResourcePair`: constant-product ERC-1155 resource AMM with 0.3% fee, slippage checks, and LP tokens.
- `LootBox`: VRF-style random rewards, paid in CRAFT and minted as ERC-1155 items.
- `CraftPriceOracle`: Chainlink AggregatorV3 adapter with stale-price checks.
- `ItemRentalVault`: state-machine rental flow for rare ERC-1155 items.
- `RentalFeeVault`: ERC-4626 tokenized vault for rental fee yield.
- `BlockCraftGovernor`, `BlockCraftTimelock`, `Treasury`: DAO control path for protocol parameters and treasury.

## Ownership

Deployment starts with a deployer admin for local setup. Production/demo handoff transfers ownership and privileged roles to `BlockCraftTimelock`; `BlockCraftGovernor` becomes the proposer and users vote with delegated CRAFT voting power.
