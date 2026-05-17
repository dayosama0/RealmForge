export function ActivityPage({ activity }: { activity: unknown[] }) {
  return (
    <section>
      <h1>Activity</h1>
      <div className="panel">
        <pre>{JSON.stringify(activity, null, 2)}</pre>
      </div>
    </section>
  );
}
