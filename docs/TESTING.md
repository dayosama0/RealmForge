# Testing Strategy

The Foundry suite is organized by intent:

- `unit`: token, item, crafting, AMM, loot, oracle, vault, governance, and factory behavior.
- `fuzz`: AMM swaps, vault deposits, governance voting power, and crafting quantities.
- `invariant`: AMM, item supply, treasury, vault, and governance invariants.
- `fork`: Chainlink, USDC, and Uniswap integration placeholders for RPC-backed runs.
- `security`: before/after reentrancy and access-control demonstrations.

Target commands:

```bash
forge build
forge test
forge coverage
```

The assignment target is at least 80 tests with coverage at or above 90%.
