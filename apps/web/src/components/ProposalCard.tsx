import { Check, Clock, Play } from "lucide-react";

export function ProposalCard({ onVote }: { onVote: () => void }) {
  return (
    <div className="panel compact">
      <div>
        <strong>Adjust loot drop rates</strong>
        <p>Queued through Governor + Timelock lifecycle.</p>
      </div>
      <div className="row">
        <button className="iconButton" onClick={onVote} title="Vote for">
          <Check size={16} />
          Vote
        </button>
        <button className="iconButton" title="Queue">
          <Clock size={16} />
          Queue
        </button>
        <button className="iconButton" title="Execute">
          <Play size={16} />
          Execute
        </button>
      </div>
    </div>
  );
}
