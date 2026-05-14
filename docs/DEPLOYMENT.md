# Deployment and Governance Lifecycle

1. Install Foundry dependencies from `packages/contracts`.
2. Run `forge script script/DeployBlockCraft.s.sol --broadcast`.
3. Update `apps/web/src/config/addresses.ts` and `packages/subgraph/subgraph.yaml` with deployed addresses.
4. Deploy or run the subgraph locally.
5. Use `GovernanceLifecycleDemo.s.sol` to create a proposal.
6. Vote through Governor.
7. Queue through Timelock after the voting period.
8. Execute after the two-day timelock delay.

The `UpgradeCraftingV2.s.sol` script demonstrates the UUPS upgrade from `CraftingManager` V1 to `CraftingManagerV2`.
