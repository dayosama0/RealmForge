import { Hammer } from "lucide-react";

const craftables = [
  { id: 101n, name: "Iron Pickaxe", recipe: "3 IRON + 2 WOOD" },
  { id: 102n, name: "Diamond Pickaxe", recipe: "3 DIAMOND + 2 WOOD" },
  { id: 103n, name: "Diamond Sword", recipe: "2 DIAMOND + 1 WOOD" },
];

export function CraftingPage({ craft }: { craft: (itemId: bigint) => void }) {
  return (
    <section>
      <h1>Crafting</h1>
      <div className="grid">
        {craftables.map((item) => (
          <div className="panel compact" key={item.name}>
            <strong>{item.name}</strong>
            <span>{item.recipe}</span>
            <button
              className="iconButton"
              onClick={() => craft(item.id)}
              title={`Craft ${item.name}`}
            >
              <Hammer size={16} />
              Craft
            </button>
          </div>
        ))}
      </div>
    </section>
  );
}
