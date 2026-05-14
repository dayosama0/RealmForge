import { Address, BigInt, Bytes } from "@graphprotocol/graph-ts";
import { ItemBalance, Player } from "../generated/schema";

export function getPlayer(address: Address): Player {
  let id = address.toHexString();
  let player = Player.load(id);
  if (player == null) {
    player = new Player(id);
    player.address = Bytes.fromHexString(id);
    player.save();
  }
  return player;
}

export function updateBalance(
  address: Address,
  itemId: BigInt,
  delta: BigInt,
): void {
  let player = getPlayer(address);
  let id = player.id.concat("-").concat(itemId.toString());
  let balance = ItemBalance.load(id);
  if (balance == null) {
    balance = new ItemBalance(id);
    balance.player = player.id;
    balance.itemId = itemId;
    balance.amount = BigInt.zero();
  }
  balance.amount = balance.amount.plus(delta);
  balance.save();
}
