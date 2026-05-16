import { useState } from "react";
import { addresses } from "../config/addresses";
import { lootAbi } from "../config/abis";
import { sendContractTx, TxState } from "./tx";

export function useLootBox(walletClient: any, account?: `0x${string}`) {
  const [tx, setTx] = useState<TxState>({ pending: false });

  async function openLootBox() {
    setTx({ pending: true });
    try {
      const hash = await sendContractTx({
        walletClient,
        account,
        address: addresses.lootBox,
        abi: lootAbi,
        functionName: "openLootBox",
      });
      setTx({ pending: false, hash });
    } catch (err) {
      setTx({
        pending: false,
        error: err instanceof Error ? err.message : "Loot box failed",
      });
    }
  }

  return { openLootBox, tx };
}
