import { KeyRound, PackagePlus } from "lucide-react";

export function RentalVaultPage({
  depositItem,
  rentItem,
}: {
  depositItem: () => void;
  rentItem: () => void;
}) {
  return (
    <section>
      <h1>Rental Vault</h1>
      <div className="panel">
        <p>
          Rare ERC-1155 tools are listed here; rental payments flow through the
          fee vault.
        </p>
        <div className="row">
          <button
            className="iconButton"
            onClick={depositItem}
            title="Deposit item"
          >
            <PackagePlus size={18} />
            Deposit Elytra
          </button>
          <button className="iconButton" onClick={rentItem} title="Rent item">
            <KeyRound size={18} />
            Rent #1
          </button>
        </div>
      </div>
    </section>
  );
}
