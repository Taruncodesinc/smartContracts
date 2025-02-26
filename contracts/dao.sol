// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

contract DAO {
    struct Proposal {
        uint id;
        uint voteCount;
        bool executed;
        string description;
        address proposedBy;
        uint proposedAt;
    }

    mapping(uint => Proposal) public totalProposals;
    Proposal[] public allProposal;
    mapping(address => Proposal[]) public proposalBy;
    mapping(uint => mapping(address => bool)) public hasVoted;
    uint public currentId = 1;
    uint public requiredVotes;
    uint public proposalDuration = 1 days;
    uint public votingEndTime;
    modifier proposalExists(uint id) {
        require(id < currentId && id > 0, "Proposal does not exist");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    event ProposalCreated(uint id, string description, address proposer);
    event Voted(uint proposalId, address voter);
    event ProposalExecuted(uint id);

    function createProposal(string calldata _description) public {
        require(bytes(_description).length > 10, "Description too short");
        votingEndTime = block.timestamp + proposalDuration;
        Proposal memory newProposal = Proposal(currentId, 0, false, _description, msg.sender, block.timestamp);
        totalProposals[currentId] = newProposal;
        allProposal.push(newProposal);
        emit ProposalCreated(currentId, _description, msg.sender);
        currentId++;
    }

    function voteForProposal(uint id) public proposalExists(id) {
        require(block.timestamp < votingEndTime, "Voting period is over");
        require(!hasVoted[id][msg.sender], "You have already voted");

        hasVoted[id][msg.sender] = true;
        totalProposals[id].voteCount++;
        emit Voted(id, msg.sender);
    }

    function setProposalExecuted() public onlyOwner {
        for (uint i = 0; i < allProposal.length; i++) {
            if (allProposal[i].voteCount >= requiredVotes && !allProposal[i].executed) {
                allProposal[i].executed = true;
                emit ProposalExecuted(allProposal[i].id);
            }
        }
    }

    function getExecuted() public view returns (Proposal memory) {
        for (uint i = 0; i < allProposal.length; i++) {
            if (allProposal[i].executed) {
                return allProposal[i];
            }
        }
        revert("No executed proposals found");
    }
}
