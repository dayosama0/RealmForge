import { ProposalCard } from "../components/ProposalCard";

export function GovernancePage({
  proposalState,
  vote,
}: {
  proposalState: string;
  vote: () => void;
}) {
  return (
    <section>
      <h1>Governance</h1>
      <div className="panel compact">
        <span>Proposal #1</span>
        <strong>State: {proposalState}</strong>
      </div>
      <ProposalCard onVote={vote} />
    </section>
  );
}
