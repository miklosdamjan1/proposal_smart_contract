const ProjectVoting = artifacts.require("ProjectVoting");

contract("ProjectVoting", (accounts) => {
  let projectVoting;

  beforeEach(async () => {
    projectVoting = await ProjectVoting.new(1);
  });

  it("should create a proposal", async () => {
    await projectVoting.createProposal("Test Proposal", Math.floor(Date.now() / 1000) + 3600, {value: 1});
    const proposal = await projectVoting.proposals(0);
    assert.equal(proposal.roadmap, "Test Proposal");
    assert.equal(proposal.yesVotes, 0);
    assert.equal(proposal.noVotes, 0);
  });

  it("should deposit funds", async () => {
    const sender = accounts[0];
    const amount = 2;
    await projectVoting.deposit({ from: sender, value: amount });
    const balance = await projectVoting.balances(sender);
    assert.equal(balance, amount);
  });

  it("should vote on a proposal", async () => {
    const sender = accounts[0];
    const proposalId = 0;
    await projectVoting.createProposal("Test Proposal", Math.floor(Date.now() / 1000) + 3600, {value: 1});
    await projectVoting.deposit({ from: sender, value: 2 });
    await projectVoting.vote(proposalId, true, { from: sender });
    const proposal = await projectVoting.proposals(proposalId);
    assert.equal(proposal.yesVotes, 1);
    assert.equal(proposal.noVotes, 0);
  });

  it("should tally the votes of a proposal", async () => {
    const sender1 = accounts[0];
    const sender2 = accounts[1];
    const proposalId = 0;
    await projectVoting.createProposal("Test Proposal", Math.floor(Date.now() / 1000) + 3600, {value: 1});
    await projectVoting.deposit({ from: sender1, value: 2 });
    await projectVoting.vote(proposalId, true, { from: sender1 });
    await projectVoting.deposit({ from: sender2, value: 1 });
    await projectVoting.vote(proposalId, false, { from: sender2 });
    const proposal = await projectVoting.proposals(proposalId);
    assert.equal(proposal.yesVotes, 1);
    assert.equal(proposal.noVotes, 1);
    await projectVoting.tallyVotes(proposalId);
    const proposalAfterTally = await projectVoting.proposals(proposalId);
    assert.equal(proposalAfterTally.yesVotes, 1);
    assert.equal(proposalAfterTally.noVotes, 1);
  });
});
