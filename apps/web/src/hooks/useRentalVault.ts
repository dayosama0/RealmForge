import { useState } from "react";
import { addresses } from "../config/addresses";
import { rentalAbi } from "../config/abis";
import { sendContractTx, TxState } from "./tx";

export function useRentalVault(walletClient: any, account?: `0x${string}`) {
  const [tx, setTx] = useState<TxState>({ pending: false });

  async function depositItem(itemId: bigint, price: bigint) {
    setTx({ pending: true });
    try {
      const hash = await sendContractTx({
        walletClient,
        account,
        address: addresses.itemRentalVault,
        abi: rentalAbi,
        functionName: "depositItem",
        args: [itemId, 1n, price, 86_400n],
      });
      setTx({ pending: false, hash });
    } catch (err) {
      setTx({
        pending: false,
        error: err instanceof Error ? err.message : "Deposit failed",
      });
    }
  }

  async function rentItem(positionId: bigint) {
    setTx({ pending: true });
    try {
      const hash = await sendContractTx({
        walletClient,
        account,
        address: addresses.itemRentalVault,
        abi: rentalAbi,
        functionName: "rentItem",
        args: [positionId, 86_400n],
      });
      setTx({ pending: false, hash });
    } catch (err) {
      setTx({
        pending: false,
        error: err instanceof Error ? err.message : "Rent failed",
      });
    }
  }

  return { depositItem, rentItem, tx };
}
