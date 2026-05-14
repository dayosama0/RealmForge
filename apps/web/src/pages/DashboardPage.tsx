import { Vote } from "lucide-react";
import { ResourceBalance } from "../components/ResourceBalance";

export function DashboardPage({
  balances,
  delegate,
}: {
  balances: Record<string, string>;
  delegate: () => void;
}) {
  return (
    <section>
      <div className="toolbar">
        <h1>BlockCraft Economy</h1>
        <button
          className="iconButton"
          onClick={delegate}
          title="Delegate votes"
        >
          <Vote size={18} />
          Delegate
        </button>
      </div>
      <div className="statsGrid">
        <div className="stat">
          <span>Protocol</span>
          <strong>GameFi Economy</strong>
        </div>
        <div className="stat">
          <span>DAO</span>
          <strong>Governor + Timelock</strong>
        </div>
        <div className="stat">
          <span>Vault</span>
          <strong>ERC-4626 fees</strong>
        </div>
        <div className="stat">
          <span>Randomness</span>
          <strong>VRF loot</strong>
        </div>
      </div>
      <ResourceBalance balances={balances} />
    </section>
  );
}
