import type { Abi } from "viem";

export type TxState = {
  pending: boolean;
  error?: string;
  hash?: `0x${string}`;
};

export async function sendContractTx(args: {
  walletClient: any;
  account?: `0x${string}`;
  address: `0x${string}`;
  abi: Abi;
  functionName: string;
  args?: readonly unknown[];
}) {
  if (!args.walletClient || !args.account)
    throw new Error("Connect wallet first");
  return args.walletClient.writeContract({
    account: args.account,
    address: args.address,
    abi: args.abi,
    functionName: args.functionName,
    args: args.args ?? [],
  });
}
