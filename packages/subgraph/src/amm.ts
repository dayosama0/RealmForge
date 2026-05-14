import { Swap } from "../generated/ResourcePair/ResourcePair";
import { SwapEvent } from "../generated/schema";
import { getPlayer } from "./helpers";

export function handleSwap(event: Swap): void {
  let entity = new SwapEvent(
    event.transaction.hash
      .toHexString()
      .concat("-")
      .concat(event.logIndex.toString()),
  );
  entity.player = getPlayer(event.params.player).id;
  entity.tokenInId = event.params.tokenInId;
  entity.tokenOutId = event.params.tokenOutId;
  entity.amountIn = event.params.amountIn;
  entity.amountOut = event.params.amountOut;
  entity.timestamp = event.block.timestamp;
  entity.save();
}
