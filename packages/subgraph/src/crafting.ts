import { Crafted } from "../generated/CraftingManager/CraftingManager";
import { CraftEvent } from "../generated/schema";
import { getPlayer } from "./helpers";

export function handleCrafted(event: Crafted): void {
  let entity = new CraftEvent(
    event.transaction.hash
      .toHexString()
      .concat("-")
      .concat(event.logIndex.toString()),
  );
  entity.player = getPlayer(event.params.player).id;
  entity.itemId = event.params.itemId;
  entity.timestamp = event.block.timestamp;
  entity.txHash = event.transaction.hash;
  entity.save();
}
