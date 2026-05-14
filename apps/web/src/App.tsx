import { useEffect, useState } from "react";
import { Backpack, Home } from "lucide-react";
import { NetworkGuard } from "./components/NetworkGuard";
import { TransactionToast } from "./components/TransactionToast";
import { WalletConnectButton } from "./components/WalletConnectButton";
import { loadDeploymentAddresses } from "./config/addresses";
import { useItems } from "./hooks/useItems";
import { useWallet } from "./hooks/useWallet";
import { DashboardPage } from "./pages/DashboardPage";
import { InventoryPage } from "./pages/InventoryPage";

const tabs = [
  ["dashboard", Home],
  ["inventory", Backpack],
] as const;

export function App() {
  const [tab, setTab] = useState<(typeof tabs)[number][0]>("dashboard");
  const [demoBalances] = useState<Record<string, string>>({
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
  const [deploymentStatus, setDeploymentStatus] = useState("loading");
  const wallet = useWallet();
  const items = useItems(wallet.publicClient, wallet.account);

  useEffect(() => {
    loadDeploymentAddresses().then((deployment) => {
      setDeploymentStatus(
        deployment.craftToken === "0x0000000000000000000000000000000000000000"
          ? "demo"
          : "local",
      );
    });
  }, []);

  const visibleBalances = wallet.account
    ? { ...demoBalances, ...items.balances }
    : demoBalances;

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
              : "Dashboard and inventory use seeded balances until contracts are deployed."}
          </span>
        </div>
        {tab === "dashboard" && (
          <DashboardPage balances={visibleBalances} delegate={() => {}} />
        )}
        {tab === "inventory" && <InventoryPage balances={visibleBalances} />}
        <TransactionToast tx={{ pending: false }} />
      </div>
    </main>
  );
}
