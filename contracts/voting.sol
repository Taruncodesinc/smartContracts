// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.2 <0.9.0;

contract Voting
{
    struct Candidate
    {
        uint id;
        bool winner;
        uint voteCount;
        address candidateAddress;
    }
    mapping (uint=>Candidate) allCandidates;
    mapping (address=>mapping (uint=>bool)) hasVoted;
    uint currentId=1;
    uint quorum;
    uint votingEndTime;

    function createCandidate() public 
    {
        Candidate memory newCandidate = Candidate(currentId, false, 0, msg.sender);
        allCandidates[currentId++]=newCandidate;
    }
    function vote(uint _id) public 
    {
        require(!hasVoted[msg.sender][_id],"you have already voted");
        require(msg.sender!=allCandidates[_id].candidateAddress,"you cannot vote yourself");
        require(_id>=1 && _id<currentId);
        allCandidates[_id].voteCount++;
        quorum++;
    }
    function checkWinner() public view  returns(Candidate memory)
    {
        require(currentId>2,"require atleast two candidates");
        for(uint i=0; i<currentId; i++)
        {
            if(allCandidates[i].voteCount>quorum && !allCandidates[i].winner)
            {
               return  allCandidates[i];
            }
        }
        Candidate memory noWinner=Candidate(0,false,0,msg.sender);
        return  noWinner;
    }
}