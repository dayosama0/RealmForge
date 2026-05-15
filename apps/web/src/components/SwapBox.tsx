import { Repeat2, Droplets } from "lucide-react";

export function SwapBox({
  onSwap,
  onAddLiquidity,
}: {
  onSwap: () => void;
  onAddLiquidity: () => void;
}) {
  return (
    <div className="panel">
      <h2>Resource AMM</h2>
      <div className="formGrid">
        <label>
          Input resource
          <select>
            <option>WOOD</option>
            <option>STONE</option>
            <option>DIAMOND</option>
          </select>
        </label>
        <label>
          Amount
          <input defaultValue="10" />
        </label>
        <label>
          Min output
          <input defaultValue="1" />
        </label>
      </div>
      <div className="row">
        <button className="iconButton" onClick={onSwap} title="Swap resources">
          <Repeat2 size={18} />
          Swap
        </button>
        <button
          className="iconButton"
          onClick={onAddLiquidity}
          title="Add liquidity"
        >
          <Droplets size={18} />
          Add liquidity
        </button>
      </div>
    </div>
  );
}
