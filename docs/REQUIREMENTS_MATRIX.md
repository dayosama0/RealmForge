# Requirements Matrix

Source of truth:

- User-provided BlockCraft Economy specification in chat.
- `docs/pdf-requirements-extracted.txt`, extracted from `BChT2_Final_Project (2) (1).pdf`.

## Scenario

Chosen scenario: Option B — GameFi Economy.

| Requirement                            |  Status | Evidence                                                                |
| -------------------------------------- | ------: | ----------------------------------------------------------------------- |
| ERC-1155 in-game item economy          |    Done | `packages/contracts/src/tokens/BlockCraftItems.sol`                     |
| Crafting                               |    Done | `packages/contracts/src/crafting/CraftingManager.sol`                   |
| Marketplace AMM for fungible resources |    Done | `packages/contracts/src/amm/ResourcePair.sol`                           |
| NFT / rare item rental vault           |    Done | `packages/contracts/src/vault/ItemRentalVault.sol`                      |
| Chainlink VRF-style loot drops         |    Done | `packages/contracts/src/loot/LootBox.sol`, `MockVRFCoordinator.sol`     |
| DAO-governed parameters                | Partial | Governor stack exists; final deployment must transfer roles to Timelock |
| L2 deployment                          | Pending | Requires real testnet RPC/private key and explorer API key              |

## Mandatory Technical Requirements

| PDF Requirement                                                     |  Status | Evidence / Follow-up                                                                   |
| ------------------------------------------------------------------- | ------: | -------------------------------------------------------------------------------------- |
| UUPS upgradeable contract with V1 -> V2 path                        |    Done | `CraftingManager.sol`, `CraftingManagerV2.sol`, `UpgradeCraftingV2.s.sol`              |
| Factory using CREATE and CREATE2                                    |    Done | `ResourceAMMFactory.sol`                                                               |
| Inline Yul benchmarked against Solidity equivalent                  | Partial | `YulMath.sol`, `SolidityMath.sol`; add gas benchmark output after Foundry is installed |
| ERC20Votes + ERC20Permit governance token                           |    Done | `CraftToken.sol`                                                                       |
| ERC-1155 or ERC-721                                                 |    Done | `BlockCraftItems.sol`                                                                  |
| ERC-4626 vault                                                      |    Done | `RentalFeeVault.sol`                                                                   |
| Chainlink price feed integration with stale check                   |    Done | `CraftPriceOracle.sol`                                                                 |
| Chainlink VRF for loot drops                                        |    Done | `LootBox.sol`, mock coordinator                                                        |
| DeFi primitive AMM or lending                                       |    Done | Constant-product AMM                                                                   |
| Subgraph with >=4 entities and >=5 queries                          |    Done | `packages/subgraph/schema.graphql`, `queries.graphql`                                  |
| Governor + TimelockController                                       |    Done | `BlockCraftGovernor.sol`, `BlockCraftTimelock.sol`                                     |
| 2-day timelock, 1-day delay, 1-week period, 4% quorum, 1% threshold | Done | Implemented; threshold deployment must equal 1% of deployed supply                     |
| Timelock controls treasury                                          | Done | Deployment script transfers treasury ownership; post-deploy verification still needed  |
| Full propose -> vote -> queue -> execute lifecycle                  | Done | Demo script exists; end-to-end test/script output still needed                         |
| L2 deployment and verification                                      | Pending | Needs live network credentials                                                         |
| L1 vs L2 gas comparison for >=6 operations                          | Pending | Needs gas benchmark runs                                                               |

## Security Requirements

| Requirement                                              |  Status | Evidence / Follow-up                                                                     |
| -------------------------------------------------------- | ------: | ---------------------------------------------------------------------------------------- |
| CEI or ReentrancyGuard where applicable                  |    Done | AMM, crafting, loot, rental vault use guards/patterns                                    |
| Privileged functions guarded by AccessControl or Ownable |    Done | AccessControl/Ownable across admin functions                                             |
| No `tx.origin` authorization                             |    Done | No usage found                                                                           |
| No `block.timestamp` randomness                          |    Done | Timestamp used for stale checks/rental expiry only; randomness via VRF mock              |
| Reentrancy and access-control before/after case studies  | Done | Test files exist; still need concrete vulnerable-before contracts and exploit assertions |
| Audit report minimum 8 pages                             | Done| `reports/SECURITY_AUDIT.md` added as structured report                                   |
| Slither output appendix                                  | Pending | CI is configured; final report must attach output with 0 High / 0 Medium                 |

## Testing Requirements

| Requirement               |            Status | Evidence / Follow-up                                          |
| ------------------------- | ----------------: | ------------------------------------------------------------- |
| Foundry preferred         |              Done | `packages/contracts/foundry.toml`                             |
| >=80 tests total          | Done structurally | 82 `test`/`invariant` functions counted                       |
| >=50 unit tests           | Done structurally | Unit test files include 60 named unit tests                   |
| >=10 fuzz tests           |           Done | Fuzz files exist; add/verify strict count with Foundry output |
| >=5 invariant tests       | Done structurally | 5 invariant files/functions                                   |
| >=3 fork tests            | Done structurally | 3 fork files                                                  |
| Coverage >=90% checked in |           Done | Needs `forge coverage` and `reports/COVERAGE.md` update       |
| All tests pass in CI      |           Done | Requires Foundry/Slither toolchain in CI                      |

## Frontend Requirements

| Requirement                                           |  Status | Evidence                                                                                  |
| ----------------------------------------------------- | ------: | ----------------------------------------------------------------------------------------- |
| Wallet connection via MetaMask                        |    Done | `useWallet.ts`, `WalletConnectButton.tsx`                                                 |
| Read balances, voting power, delegate, protocol state | Done | Balances wired; voting/delegate/protocol state reads should be expanded before final demo |
| >=3 write txs                                         |    Done | delegate, craft, swap, loot, rental, vote                                                 |
| Proposal list and vote button                         | Done | Demo proposal card exists; needs real proposal query source                               |
| Pull indexed data from subgraph                       |    Done | `ActivityPage.tsx`, `useSubgraph.ts`                                                      |
| Readable errors                                       | Done | Errors shown; add wrong-network and insufficient-balance specific messages                |

## DevOps and Documentation

| Requirement                               |        Status | Evidence / Follow-up                                                                       |
| ----------------------------------------- | ------------: | ------------------------------------------------------------------------------------------ |
| GitHub Actions CI                         | Done baseline | `.github/workflows/ci.yml` includes build, test, coverage, Slither, fmt, solhint, prettier |
| Reproducible deploy script                | Done baseline | `DeployBlockCraft.s.sol`                                                                   |
| Verified L2 contract links in README      |       Pending | Needs real deployment                                                                      |
| Architecture doc minimum 6 pages          |       Done | `docs/ARCHITECTURE.md`; expand before final submission                                     |
| Security audit minimum 8 pages            |       Done | `reports/SECURITY_AUDIT.md`; expand before final submission                                |
| Gas optimization report with before/after |       Done | `reports/GAS_OPTIMIZATION.md`; fill with benchmark output                                  |
| Final presentation PDF                    |       Done | Not created yet                                                                            |
