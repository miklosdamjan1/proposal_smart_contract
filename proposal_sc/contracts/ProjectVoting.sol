// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

struct Proposal {
    uint256 id;
    string roadmap;
    uint256 yesVotes;
    uint256 noVotes;
    uint256 deadline;
}

contract ProjectVoting {
    uint256 public proposalCount;
    uint256 public minimumBalance;

    Proposal[] public proposals;
    mapping(address => uint256) public balances;
    mapping(address => mapping(uint256 => bool)) public hasVoted;

    event ProposalCreated(uint256 proposalId, string roadmap, uint256 deadline);
    event Deposit(address sender, uint256 amount);
    event VoteCast(uint256 proposalId, address voter, bool vote);
    event VotesTallied(uint256 proposalId, uint256 yesVotes, uint256 noVotes);

    constructor(uint256 _minimumBalance) {
        minimumBalance = _minimumBalance;
    }

    function createProposal(string memory roadmap, uint256 deadline) public payable {
        require(msg.value >= minimumBalance, "Insufficient balance");
        require(deadline > 0, "Invalid deadline");
        proposals.push(Proposal(proposalCount, roadmap, 0, 0, deadline));
        emit ProposalCreated(proposalCount, roadmap, deadline);
        proposalCount++;
        balances[msg.sender] += msg.value;
    }


    function deposit() public payable {
        require(msg.value > 0, "Amount must be greater than 0");
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }


    function vote(uint256 proposalId, bool vote) public {
        require(proposalId < proposalCount, "Invalid proposal ID");
        require(balances[msg.sender] >= minimumBalance, "Insufficient balance");
        require(!hasVoted[msg.sender][proposalId], "Already voted on this proposal");
        Proposal storage proposal = proposals[proposalId];
        if (vote) {
            proposal.yesVotes++;
        } else {
            proposal.noVotes++;
        }
        hasVoted[msg.sender][proposalId] = true;
        emit VoteCast(proposalId, msg.sender, vote);
    }

    function tallyVotes(uint256 proposalId) external {
		require(proposalId < proposalCount, "Invalid proposal ID");
		Proposal storage proposal = proposals[proposalId];
		uint256 totalVotes = proposal.yesVotes + proposal.noVotes;
		require(totalVotes > 0, "No votes cast");
		uint256 yesPercentage = (proposal.yesVotes * 100) / totalVotes;
		if (yesPercentage >= 50) {
		}
		emit VotesTallied(proposalId, proposal.yesVotes, proposal.noVotes);
	}

}