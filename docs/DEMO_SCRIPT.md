# Demo Script

Use this script to show the project before live L2 deployment is complete.

## Start Frontend

```powershell
cd "C:\Users\Thinkpad T16\Desktop\finale blockchain"
npm install
npm run web:dev
```

Open:

```text
http://127.0.0.1:5173/
```

## Demo Flow

1. Dashboard

   - Show protocol modules: GameFi economy, DAO, ERC-4626 vault, VRF loot.
   - Show ERC-1155 resource balances.

2. Crafting

   - Open `crafting`.
   - Craft `Diamond Pickaxe` or `Iron Pickaxe`.
   - Explain that `CraftingManager` burns ERC-1155 resources and mints crafted ERC-1155 items.

3. Swap

   - Open `swap`.
   - Click `Swap`.
   - Explain constant-product AMM, 0.3% fee, LP token, and slippage protection.

4. Loot

   - Open `loot`.
   - Click `Open`.
   - Explain Chainlink VRF-style randomness and DAO-controlled drop rates.

5. Rental

   - Open `rental`.
   - Click `Deposit Elytra`.
   - Click `Rent #1`.
   - Explain rare item rental and rental fee routing to the ERC-4626 vault.

6. Governance

   - Open `governance`.
   - Click `Vote`.
   - Explain Governor + Timelock lifecycle: propose -> vote -> queue -> execute.

7. Activity
   - Open `activity`.
   - Show the resulting event log.
   - Explain that the live version reads protocol activity through The Graph subgraph.

## What To Say Clearly

This is a demo-ready frontend connected to the repository architecture. The contracts, tests, subgraph, scripts, and docs are present in the repo. Final production-grade submission still needs Foundry test/coverage output, Slither output, L2 deployment, explorer verification links, and filled gas report.
