import { useEffect, useState } from "react";
import { formatUnits } from "viem";
import { addresses } from "../config/addresses";
import { itemsAbi } from "../config/abis";
import { resources, rareItems } from "../config/items";

export function useItems(publicClient: any, account?: `0x${string}`) {
  const [balances, setBalances] = useState<Record<string, string>>({});

  useEffect(() => {
    if (!account) return;
    let cancelled = false;
    Promise.all(
      [...resources, ...rareItems].map(async (item) => {
        const value = await publicClient.readContract({
          address: addresses.items,
          abi: itemsAbi,
          functionName: "balanceOf",
          args: [account, item.id],
        });
        return [item.id.toString(), formatUnits(value as bigint, 0)] as const;
      }),
    )
      .then((entries) => {
        if (!cancelled) setBalances(Object.fromEntries(entries));
      })
      .catch(() => setBalances({}));
    return () => {
      cancelled = true;
    };
  }, [account, publicClient]);

  return { balances };
}
