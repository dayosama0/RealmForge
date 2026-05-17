import { useEffect, useState } from "react";
import { addresses } from "../config/addresses";
import { PROTOCOL_ACTIVITY_QUERY } from "../graphql/queries";

export function useSubgraph() {
  const [activity, setActivity] = useState<unknown[]>([]);

  useEffect(() => {
    fetch(addresses.subgraph, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ query: PROTOCOL_ACTIVITY_QUERY }),
    })
      .then((r) => r.json())
      .then((json) => setActivity(json.data?.craftEvents ?? []))
      .catch(() => setActivity([]));
  }, []);

  return { activity };
}
