// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Voting {
    address private owner;
    uint64 public nextId;
    Proposal[] public proposals;
    bool someoneVoted = false;

    struct Proposal {
        uint64 id;
        string name;
    }

    event ProposalVoted(uint64 proposalId);
    event WinningProposal(uint64 idOfWinner, uint64 votes);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    mapping(uint64 proposalId => uint64 votes) ballot;
    mapping(address voter => bool hasVoted) voters;

    function addProposal(string memory _name) public onlyOwner {
        proposals.push(Proposal({id: nextId, name: _name}));
        //ballot[nextId] = 0; check if you need to create this or not for zero values
        nextId++;
    }

    function getProposalVotes(uint64 _proposalId) public view returns (uint64) {
        return ballot[_proposalId];
    }

    function voteProposal(uint64 _proposalId) public {
        require(!voters[msg.sender], "This person has already voted");
        ballot[_proposalId]++;
        voters[msg.sender] == true;
        if (!someoneVoted) someoneVoted = true;
        emit ProposalVoted(_proposalId);
    }

    function getBallot(uint64 _proposalId) public view returns (uint64) {
        return ballot[_proposalId];
    }

    // For demo purposes only: no time limit and no tie handling
    function finishVoting() public onlyOwner {
        uint64 idOfWinner;
        uint64 winnerVotes;
        require(nextId > 0, "No proposals submitted");
        require(someoneVoted, "No votes submitted");
        for (uint64 i = 0; i < nextId; i++) {
            if (ballot[i] > 0 && ballot[i] > winnerVotes) {
                idOfWinner = i;
                winnerVotes = ballot[i];
            }
        }
        emit WinningProposal(idOfWinner, winnerVotes);
    }
}
