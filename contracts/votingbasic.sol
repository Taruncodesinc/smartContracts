// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

contract myContract {
    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }

    mapping (uint => Candidate) allCandidates;
    mapping (address => bool) hasVoted;
    address public owner;
    uint public candidateCount;
    uint currentId = 1;  // Start candidate IDs from 1

    modifier validId(uint id) {
        require(id > 0 && id < currentId, "not a valid id");
        _;
    }

    modifier hasNotVoted() {
        require(!hasVoted[msg.sender], "You have already voted");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Function to add a candidate
    function addCandidate(string calldata _name) public {
        allCandidates[currentId] = Candidate(currentId, _name, 0);
        candidateCount++;
        currentId++;
    }

    // Function to vote for a candidate
    function vote(uint _candidateId) public validId(_candidateId) hasNotVoted {
        allCandidates[_candidateId].voteCount++;
        hasVoted[msg.sender] = true;
    }

    function getVoteCount(uint _candidateId) public view returns (uint) {
        return allCandidates[_candidateId].voteCount;
    }

    function getWinner() public view returns (Candidate memory) {
        uint maxVote = 0;
        uint winnerId = 0;
        require(currentId > 1, "No candidates available");

        for (uint i = 1; i < currentId; i++) {
            if (allCandidates[i].voteCount > maxVote) {
                winnerId = i;
                maxVote = allCandidates[i].voteCount;
            }
        }
        return allCandidates[winnerId];
    }
}
