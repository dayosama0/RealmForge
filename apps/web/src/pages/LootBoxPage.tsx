import { Box } from "lucide-react";

export function LootBoxPage({ openLootBox }: { openLootBox: () => void }) {
  return (
    <section>
      <h1>Loot Box</h1>
      <div className="panel">
        <p>
          VRF-backed rewards: resources, enchanted books, Elytra, and Dragon
          Egg.
        </p>
        <button
          className="iconButton"
          onClick={openLootBox}
          title="Open loot box"
        >
          <Box size={18} />
          Open
        </button>
      </div>
    </section>
  );
}
