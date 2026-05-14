import { resources } from "../config/items";
import { ItemCard } from "./ItemCard";

export function ResourceBalance({
  balances,
}: {
  balances: Record<string, string>;
}) {
  return (
    <div className="grid">
      {resources.map((item) => (
        <ItemCard
          key={item.code}
          name={item.name}
          tone={item.tone}
          balance={balances[item.id.toString()]}
        />
      ))}
    </div>
  );
}
