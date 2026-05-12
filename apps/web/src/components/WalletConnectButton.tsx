import { Wallet } from "lucide-react";

export function WalletConnectButton({
  account,
  connect,
}: {
  account?: string;
  connect: () => void;
}) {
  return (
    <button className="iconButton" onClick={connect} title="Connect wallet">
      <Wallet size={18} />
      <span>
        {account ? `${account.slice(0, 6)}...${account.slice(-4)}` : "Connect"}
      </span>
    </button>
  );
}
