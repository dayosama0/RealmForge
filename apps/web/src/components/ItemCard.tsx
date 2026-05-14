export function ItemCard({
  name,
  balance,
  tone,
}: {
  name: string;
  balance?: string;
  tone?: string;
}) {
  return (
    <div className="itemCard">
      <span className="swatch" style={{ background: tone ?? "#334155" }} />
      <strong>{name}</strong>
      <span>{balance ?? "0"}</span>
    </div>
  );
}
