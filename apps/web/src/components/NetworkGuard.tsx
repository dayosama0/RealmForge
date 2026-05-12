export function NetworkGuard({ error }: { error?: string }) {
  if (!error) return null;
  return <div className="notice">{error}</div>;
}
