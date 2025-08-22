// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Voting} from "../src/Voting.sol";

contract VotingTest is Test {
    Voting public voting;

    function test_voting() public {
        voting = new Voting();

        // Two proposals added
        voting.addProposal("EIP-6999");
        voting.addProposal("EIP-7833");

        // Votes
        vm.prank(address(0x1));
        voting.voteProposal(0);
        vm.prank(address(0x2));
        voting.voteProposal(1);
        vm.prank(address(0x3));
        voting.voteProposal(1);
        vm.prank(address(0x4));
        voting.voteProposal(1);
        vm.prank(address(0x5));
        voting.voteProposal(0); // Proposal 1 should win

        // Verify votes
        vm.prank(address(0x6));
        vm.expectRevert("Not owner");
        voting.finishVoting();

        // Correct owner
        voting.finishVoting();
    }
}
