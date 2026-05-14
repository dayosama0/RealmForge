import { LootFulfilled } from "../generated/LootBox/LootBox";
import { LootDrop } from "../generated/schema";
import { getPlayer } from "./helpers";

export function handleLootFulfilled(event: LootFulfilled): void {
  let entity = new LootDrop(
    event.transaction.hash
      .toHexString()
      .concat("-")
      .concat(event.logIndex.toString()),
  );
  entity.player = getPlayer(event.params.player).id;
  entity.requestId = event.params.requestId;
  entity.rewardItemId = event.params.rewardItemId;
  entity.rewardAmount = event.params.rewardAmount;
  entity.timestamp = event.block.timestamp;
  entity.save();
}
