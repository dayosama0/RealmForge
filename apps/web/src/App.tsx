import { useState } from "react";
import { Backpack, Home } from "lucide-react";
import { NetworkGuard } from "./components/NetworkGuard";
import { TransactionToast } from "./components/TransactionToast";
import { WalletConnectButton } from "./components/WalletConnectButton";
import { useWallet } from "./hooks/useWallet";

const tabs = [
  ["dashboard", Home],
  ["inventory", Backpack],
] as const;

export function App() {
  const [tab, setTab] = useState<(typeof tabs)[number][0]>("dashboard");
  const wallet = useWallet();

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
        {tab === "dashboard" && (
          <section className="panel compact">
            <h1>Dashboard</h1>
            <p>Wallet connectivity and navigation shell are ready.</p>
          </section>
        )}
        {tab === "inventory" && (
          <section className="panel compact">
            <h1>Inventory</h1>
            <p>Resource and item panels land in the next pass.</p>
          </section>
        )}
        <TransactionToast tx={{ pending: false }} />
      </div>
    </main>
  );
}
