import { useCallback, useMemo, useState } from "react";
import {
  createPublicClient,
  createWalletClient,
  custom,
  http,
  type EIP1193Provider,
} from "viem";
import { foundry } from "viem/chains";
import { localChain } from "../config/chains";

declare global {
  interface Window {
    ethereum?: unknown;
  }
}

export function useWallet() {
  const [account, setAccount] = useState<`0x${string}` | undefined>();
  const [error, setError] = useState<string>();

  const publicClient = useMemo(
    () =>
      createPublicClient({
        chain: foundry,
        transport: http(localChain.rpcUrl),
      }),
    [],
  );

  const walletClient = useMemo(() => {
    if (!window.ethereum) return undefined;
    return createWalletClient({
      chain: foundry,
      transport: custom(window.ethereum as EIP1193Provider),
    });
  }, []);

  const connect = useCallback(async () => {
    try {
      if (!walletClient) throw new Error("Wallet extension not detected");
      const [address] = await walletClient.requestAddresses();
      setAccount(address);
      setError(undefined);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Wallet connection failed");
    }
  }, [walletClient]);

  return { account, connect, error, publicClient, walletClient };
}
