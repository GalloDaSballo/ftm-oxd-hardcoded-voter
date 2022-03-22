// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import {IVotingSnapshot, Vote} from "../interfaces/oxd/IVotingSnapshot.sol";

contract HardcodedVoter {
  address governance;
  address friend; // Additional contract that can undo voting

  IVotingSnapshot constant VOTING_SNAPSHOT = IVotingSnapshot(0xd9671aa5B790127FC1aA9B706CB3BD7889D9e9B8);

  address constant POOL =  0x6058345A4D8B89Ddac7042Be08091F91a404B80b; // wBTC / renBTC 

  constructor(address newGovernance, address newFriend) {
    governance = newGovernance;
    friend = newFriend;
  }

  function setFriend(address newFriend) external {
    require(msg.sender == governance);

    friend = newFriend;
  }

  function renounceOwnership() external {
    require(msg.sender == governance);

    governance = address(0);
    friend = address(0);
  }


  /// @dev Casts vote to target contract
  /// @notice Can be called by anyone as our votes are hardcoded
  /// @notice For user security, check how delegation is handled at the strategy level
  function vote() external {
    // Get Total Votes we got
    int256 totalVotes = int256(VOTING_SNAPSHOT.voteWeightTotalByAccount(address(this)));

    // We hardcode our votes here
    Vote[] memory votes = new Vote[](1);
    votes[0] = Vote(POOL, totalVotes);

    // NOTE: If you had multiple pools this is where you can split by ratios
    // NOTE: Not needed in this version

    // Vote
    VOTING_SNAPSHOT.vote(votes);
  }

  /// @dev Undoes the vote
  /// @notice Can be called by gov or friend exclusively
  /// @notice To be used before migrating delegate
  function undoVote() external {
    require(msg.sender == governance || msg.sender == friend);

    // Get Total Votes we got
    int256 totalVotes = int256(VOTING_SNAPSHOT.voteWeightTotalByAccount(address(this)));

    // We hardcode our votes here
    Vote[] memory votes = new Vote[](1);
    votes[0] = Vote(POOL, -totalVotes);

    // NOTE: If you had multiple pools this is where you can split by ratios
    // NOTE: Not needed in this version

    // Vote
    VOTING_SNAPSHOT.vote(votes);
  }
}