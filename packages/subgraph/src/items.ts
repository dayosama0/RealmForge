import { BigInt } from "@graphprotocol/graph-ts";
import { TransferSingle } from "../generated/BlockCraftItems/BlockCraftItems";
import { updateBalance } from "./helpers";

export function handleTransferSingle(event: TransferSingle): void {
  if (
    event.params.from.toHexString() !=
    "0x0000000000000000000000000000000000000000"
  ) {
    updateBalance(event.params.from, event.params.id, event.params.value.neg());
  }
  if (
    event.params.to.toHexString() !=
    "0x0000000000000000000000000000000000000000"
  ) {
    updateBalance(event.params.to, event.params.id, event.params.value);
  }
  BigInt.zero();
}
