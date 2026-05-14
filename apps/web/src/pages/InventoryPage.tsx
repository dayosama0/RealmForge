import { rareItems } from "../config/items";
import { ItemCard } from "../components/ItemCard";

export function InventoryPage({
  balances,
}: {
  balances: Record<string, string>;
}) {
  return (
    <section>
      <h1>Inventory</h1>
      <div className="grid">
        {rareItems.map((item) => (
          <ItemCard
            key={item.id.toString()}
            name={item.name}
            balance={balances[item.id.toString()]}
          />
        ))}
      </div>
    </section>
  );
}
