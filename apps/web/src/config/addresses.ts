export type AddressConfig = {
  craftToken: `0x${string}`;
  items: `0x${string}`;
  craftingManager: `0x${string}`;
  ammFactory: `0x${string}`;
  woodStonePair: `0x${string}`;
  lootBox: `0x${string}`;
  itemRentalVault: `0x${string}`;
  governor: `0x${string}`;
  subgraph: string;
};

const zero = "0x0000000000000000000000000000000000000000" as const;

export const addresses: AddressConfig = {
  craftToken: zero,
  items: zero,
  craftingManager: zero,
  ammFactory: zero,
  woodStonePair: zero,
  lootBox: zero,
  itemRentalVault: zero,
  governor: zero,
  subgraph: "http://localhost:8000/subgraphs/name/blockcraft",
};

type DeploymentJson = Partial<
  Omit<AddressConfig, "craftingManager" | "subgraph"> & {
    craftingProxy: `0x${string}`;
    subgraph: string;
  }
>;

export async function loadDeploymentAddresses() {
  try {
    const response = await fetch("/deployments/31337.json", {
      cache: "no-store",
    });
    if (!response.ok) return addresses;
    const deployment = (await response.json()) as DeploymentJson;
    addresses.craftToken = deployment.craftToken ?? addresses.craftToken;
    addresses.items = deployment.items ?? addresses.items;
    addresses.craftingManager =
      deployment.craftingProxy ?? addresses.craftingManager;
    addresses.ammFactory = deployment.ammFactory ?? addresses.ammFactory;
    addresses.woodStonePair =
      deployment.woodStonePair ?? addresses.woodStonePair;
    addresses.lootBox = deployment.lootBox ?? addresses.lootBox;
    addresses.itemRentalVault =
      deployment.itemRentalVault ?? addresses.itemRentalVault;
    addresses.governor = deployment.governor ?? addresses.governor;
    addresses.subgraph = deployment.subgraph ?? addresses.subgraph;
  } catch {
    return addresses;
  }
  return addresses;
}
