import { useState } from "react";
import { pairAbi } from "../config/abis";
import { addresses } from "../config/addresses";
import { sendContractTx, TxState } from "./tx";

export function useSwap(walletClient: any, account?: `0x${string}`) {
  const [tx, setTx] = useState<TxState>({ pending: false });

  async function swap(
    tokenInId: bigint,
    amountIn: bigint,
    minAmountOut: bigint,
  ) {
    setTx({ pending: true });
    try {
      const hash = await sendContractTx({
        walletClient,
        account,
        address: addresses.woodStonePair,
        abi: pairAbi,
        functionName: "swapExactInput",
        args: [tokenInId, amountIn, minAmountOut],
      });
      setTx({ pending: false, hash });
    } catch (err) {
      setTx({
        pending: false,
        error: err instanceof Error ? err.message : "Swap failed",
      });
    }
  }

  async function addLiquidity(amount0: bigint, amount1: bigint) {
    setTx({ pending: true });
    try {
      const hash = await sendContractTx({
        walletClient,
        account,
        address: addresses.woodStonePair,
        abi: pairAbi,
        functionName: "addLiquidity",
        args: [amount0, amount1, 1n],
      });
      setTx({ pending: false, hash });
    } catch (err) {
      setTx({
        pending: false,
        error: err instanceof Error ? err.message : "Add liquidity failed",
      });
    }
  }

  return { swap, addLiquidity, tx };
}
