import { useState } from "react";
import { addresses } from "../config/addresses";
import { craftingAbi } from "../config/abis";
import { sendContractTx, TxState } from "./tx";

export function useCrafting(walletClient: any, account?: `0x${string}`) {
  const [tx, setTx] = useState<TxState>({ pending: false });

  async function craft(itemId: bigint) {
    setTx({ pending: true });
    try {
      const hash = await sendContractTx({
        walletClient,
        account,
        address: addresses.craftingManager,
        abi: craftingAbi,
        functionName: "craft",
        args: [itemId],
      });
      setTx({ pending: false, hash });
    } catch (err) {
      setTx({
        pending: false,
        error: err instanceof Error ? err.message : "Craft failed",
      });
    }
  }

  return { craft, tx };
}
