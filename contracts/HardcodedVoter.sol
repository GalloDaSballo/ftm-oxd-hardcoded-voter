// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import {IVotingSnapshot} from "../interfaces/oxd/IVotingSnapshot.sol";

contract HardcodedVoter {
  address immutable governance;
  address immutable strategy;

  IVotingSnapshot constant VOTING_SNAPSHOT = IVotingSnapshot(0xd9671aa5B790127FC1aA9B706CB3BD7889D9e9B8);

  address constant POOL =  0x6058345A4D8B89Ddac7042Be08091F91a404B80b; // wBTC / renBTC 

  constructor(address newGovernance, address newStrategy) {
    governance = newGovernance;
    strategy = newStrategy;
  }

  /// @dev Casts vote to target contract
  /// @notice Can be called by anyone as our votes are hardcoded
  /// @notice For user security, check how delegation is handled at the strategy level
  function vote() external {
    // Get Total Votes we got
    int256 totalVotes = int256(VOTING_SNAPSHOT.voteWeightTotalByAccount(address(this)));

    // NOTE: If you had multiple pools this is where you can split by ratios
    // NOTE: Not needed in this version

    // Vote
    VOTING_SNAPSHOT.vote(strategy, POOL, totalVotes);
  }

  /// @dev Undoes the vote
  /// @notice Can be called by gov exclusively
  /// @notice To be used before migrating delegate
  function undoVote(int256 max) external {
    require(msg.sender == governance);

    // Get Total Votes we got
    int256 totalVotes = int256(VOTING_SNAPSHOT.voteWeightTotalByAccount(address(this)));
    
    // Added this extra check just in case as the `voteWeightTotalByAccount` may have changed
    // And we don't want to underflow
    if(max < totalVotes) {
      totalVotes = max;
    }

    // Vote
    VOTING_SNAPSHOT.vote(strategy, POOL, -totalVotes);
  }
}