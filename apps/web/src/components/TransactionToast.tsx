import type { TxState } from "../hooks/tx";

export function TransactionToast({ tx }: { tx: TxState }) {
  if (!tx.pending && !tx.error && !tx.hash) return null;
  return (
    <div className="toast">
      {tx.pending && "Transaction pending"}
      {tx.error && tx.error}
      {tx.hash && `Submitted ${tx.hash.slice(0, 10)}...`}
    </div>
  );
}
