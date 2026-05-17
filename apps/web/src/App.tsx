import { useEffect, useState } from "react";
import {
  Activity,
  Backpack,
  Boxes,
  Hammer,
  Home,
  Repeat2,
  ScrollText,
  Vault,
} from "lucide-react";
import { WalletConnectButton } from "./components/WalletConnectButton";
import { NetworkGuard } from "./components/NetworkGuard";
import { TransactionToast } from "./components/TransactionToast";
import { DashboardPage } from "./pages/DashboardPage";
import { InventoryPage } from "./pages/InventoryPage";
import { CraftingPage } from "./pages/CraftingPage";
import { SwapPage } from "./pages/SwapPage";
import { LootBoxPage } from "./pages/LootBoxPage";
import { RentalVaultPage } from "./pages/RentalVaultPage";
import { GovernancePage } from "./pages/GovernancePage";
import { ActivityPage } from "./pages/ActivityPage";
import { useWallet } from "./hooks/useWallet";
import { useItems } from "./hooks/useItems";
import { useCrafting } from "./hooks/useCrafting";
import { useSwap } from "./hooks/useSwap";
import { useLootBox } from "./hooks/useLootBox";
import { useRentalVault } from "./hooks/useRentalVault";
import { useGovernance } from "./hooks/useGovernance";
import { useSubgraph } from "./hooks/useSubgraph";
import { loadDeploymentAddresses } from "./config/addresses";

const tabs = [
  ["dashboard", Home],
  ["inventory", Backpack],
  ["crafting", Hammer],
  ["swap", Repeat2],
  ["loot", Boxes],
  ["rental", Vault],
  ["governance", ScrollText],
  ["activity", Activity],
] as const;

export function App() {
  const [tab, setTab] = useState<(typeof tabs)[number][0]>("dashboard");
  const [demoBalances, setDemoBalances] = useState<Record<string, string>>({
    "1": "64",
    "2": "48",
    "3": "24",
    "4": "12",
    "5": "9",
    "6": "5",
    "7": "30",
    "101": "0",
    "102": "0",
    "103": "0",
    "104": "1",
    "105": "1",
    "106": "0",
  });
  const [demoActivity, setDemoActivity] = useState<string[]>([
    "Wallet-ready demo state loaded",
    "Initial ERC-1155 resources minted for player inventory",
  ]);
  const [proposalState, setProposalState] = useState("Active");
  const [deploymentStatus, setDeploymentStatus] = useState("loading");
  const wallet = useWallet();
  const items = useItems(wallet.publicClient, wallet.account);
  const crafting = useCrafting(wallet.walletClient, wallet.account);
  const swap = useSwap(wallet.walletClient, wallet.account);
  const loot = useLootBox(wallet.walletClient, wallet.account);
  const rental = useRentalVault(wallet.walletClient, wallet.account);
  const governance = useGovernance(wallet.walletClient, wallet.account);
  const subgraph = useSubgraph();

  useEffect(() => {
    loadDeploymentAddresses().then((deployment) => {
      setDeploymentStatus(
        deployment.craftToken === "0x0000000000000000000000000000000000000000"
          ? "demo"
          : "local",
      );
    });
  }, []);
  const activeTx =
    crafting.tx.pending || crafting.tx.error || crafting.tx.hash
      ? crafting.tx
      : swap.tx.pending || swap.tx.error || swap.tx.hash
        ? swap.tx
        : loot.tx.pending || loot.tx.error || loot.tx.hash
          ? loot.tx
          : rental.tx.pending || rental.tx.error || rental.tx.hash
            ? rental.tx
            : governance.tx;
  const visibleBalances = wallet.account
    ? { ...demoBalances, ...items.balances }
    : demoBalances;

  function pushActivity(message: string) {
    setDemoActivity((events) => [message, ...events].slice(0, 12));
  }

  function bumpBalance(id: string, delta: number) {
    setDemoBalances((balances) => {
      const current = Number(balances[id] ?? "0");
      return { ...balances, [id]: Math.max(0, current + delta).toString() };
    });
  }

  function demoDelegate() {
    setProposalState("Voting power delegated");
    pushActivity("Delegated CRAFT voting power to player");
  }

  function demoCraft(itemId: bigint) {
    if (itemId === 101n) {
      bumpBalance("3", -3);
      bumpBalance("1", -2);
    }
    if (itemId === 102n) {
      bumpBalance("5", -3);
      bumpBalance("1", -2);
    }
    if (itemId === 103n) {
      bumpBalance("5", -2);
      bumpBalance("1", -1);
    }
    bumpBalance(itemId.toString(), 1);
    pushActivity(`Crafted item #${itemId.toString()} through CraftingManager`);
  }

  function demoSwap() {
    bumpBalance("1", -10);
    bumpBalance("2", 9);
    pushActivity("Swapped 10 WOOD for 9 STONE through ResourcePair AMM");
  }

  function demoAddLiquidity() {
    bumpBalance("1", -10);
    bumpBalance("2", -10);
    pushActivity("Added WOOD/STONE liquidity and received bcLP shares");
  }

  function demoLoot() {
    bumpBalance("104", 1);
    pushActivity("Opened VRF loot box and received ENCHANTED_BOOK");
  }

  function demoDepositRental() {
    bumpBalance("105", -1);
    pushActivity("Deposited ELYTRA into ItemRentalVault position #1");
  }

  function demoRent() {
    pushActivity(
      "Rented position #1; CRAFT fee routed to ERC-4626 RentalFeeVault",
    );
  }

  function demoVote() {
    setProposalState("Succeeded");
    pushActivity("Voted FOR proposal: adjust loot drop rates");
  }

  return (
    <main>
      <aside>
        <div className="brand">BlockCraft</div>
        <nav>
          {tabs.map(([id, Icon]) => (
            <button
              key={id}
              className={tab === id ? "active" : ""}
              onClick={() => setTab(id)}
              title={id}
            >
              <Icon size={18} />
              <span>{id}</span>
            </button>
          ))}
        </nav>
      </aside>
      <div className="content">
        <header>
          <NetworkGuard error={wallet.error} />
          <WalletConnectButton
            account={wallet.account}
            connect={wallet.connect}
          />
        </header>
        <div className="demoBanner">
          <strong>
            {deploymentStatus === "local" ? "Local deployment" : "Demo mode"}
          </strong>
          <span>
            {deploymentStatus === "local"
              ? "Frontend loaded contract addresses from public/deployments/31337.json."
              : "Actions simulate the full GameFi flow until contracts are deployed locally or to an L2 testnet."}
          </span>
        </div>
        {tab === "dashboard" && (
          <DashboardPage
            balances={visibleBalances}
            delegate={wallet.account ? governance.delegate : demoDelegate}
          />
        )}
        {tab === "inventory" && <InventoryPage balances={visibleBalances} />}
        {tab === "crafting" && (
          <CraftingPage craft={wallet.account ? crafting.craft : demoCraft} />
        )}
        {tab === "swap" && (
          <SwapPage
            onSwap={wallet.account ? () => swap.swap(1n, 10n, 1n) : demoSwap}
            onAddLiquidity={
              wallet.account
                ? () => swap.addLiquidity(100n, 100n)
                : demoAddLiquidity
            }
          />
        )}
        {tab === "loot" && (
          <LootBoxPage
            openLootBox={wallet.account ? loot.openLootBox : demoLoot}
          />
        )}
        {tab === "rental" && (
          <RentalVaultPage
            depositItem={
              wallet.account
                ? () => rental.depositItem(105n, 1_000_000_000_000_000_000n)
                : demoDepositRental
            }
            rentItem={wallet.account ? () => rental.rentItem(1n) : demoRent}
          />
        )}
        {tab === "governance" && (
          <GovernancePage
            proposalState={proposalState}
            vote={wallet.account ? () => governance.vote(1n, 1) : demoVote}
          />
        )}
        {tab === "activity" && (
          <ActivityPage
            activity={
              subgraph.activity.length ? subgraph.activity : demoActivity
            }
          />
        )}
        <TransactionToast tx={activeTx} />
      </div>
    </main>
  );
}
