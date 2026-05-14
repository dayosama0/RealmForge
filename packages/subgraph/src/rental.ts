import {
  ItemRented,
  ItemReturned,
  RentalListed,
} from "../generated/ItemRentalVault/ItemRentalVault";
import { RentalPosition } from "../generated/schema";
import { getPlayer } from "./helpers";

export function handleRentalListed(event: RentalListed): void {
  let entity = new RentalPosition(event.params.positionId.toString());
  entity.lender = getPlayer(event.params.lender).id;
  entity.renter = null;
  entity.itemId = event.params.itemId;
  entity.status = "Available";
  entity.price = event.params.price;
  entity.expiresAt = null;
  entity.save();
}

export function handleItemRented(event: ItemRented): void {
  let entity = RentalPosition.load(event.params.positionId.toString());
  if (entity == null) return;
  entity.renter = getPlayer(event.params.renter).id;
  entity.status = "Rented";
  entity.expiresAt = event.params.expiresAt;
  entity.save();
}

export function handleItemReturned(event: ItemReturned): void {
  let entity = RentalPosition.load(event.params.positionId.toString());
  if (entity == null) return;
  entity.status = "Returned";
  entity.save();
}
