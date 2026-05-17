import { useState } from "react";
import { addresses } from "../config/addresses";
import { erc20VotesAbi, governorAbi } from "../config/abis";
import { sendContractTx, TxState } from "./tx";

export function useGovernance(walletClient: any, account?: `0x${string}`) {
  const [tx, setTx] = useState<TxState>({ pending: false });

  async function delegate() {
    setTx({ pending: true });
    try {
      const hash = await sendContractTx({
        walletClient,
        account,
        address: addresses.craftToken,
        abi: erc20VotesAbi,
        functionName: "delegate",
        args: [account],
      });
      setTx({ pending: false, hash });
    } catch (err) {
      setTx({
        pending: false,
        error: err instanceof Error ? err.message : "Delegate failed",
      });
    }
  }

  async function vote(proposalId: bigint, support: number) {
    setTx({ pending: true });
    try {
      const hash = await sendContractTx({
        walletClient,
        account,
        address: addresses.governor,
        abi: governorAbi,
        functionName: "castVote",
        args: [proposalId, support],
      });
      setTx({ pending: false, hash });
    } catch (err) {
      setTx({
        pending: false,
        error: err instanceof Error ? err.message : "Vote failed",
      });
    }
  }

  return { delegate, vote, tx };
}
