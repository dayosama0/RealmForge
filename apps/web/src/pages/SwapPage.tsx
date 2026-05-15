import { SwapBox } from "../components/SwapBox";

export function SwapPage({
  onSwap,
  onAddLiquidity,
}: {
  onSwap: () => void;
  onAddLiquidity: () => void;
}) {
  return (
    <section>
      <h1>Swap</h1>
      <SwapBox onSwap={onSwap} onAddLiquidity={onAddLiquidity} />
    </section>
  );
}
