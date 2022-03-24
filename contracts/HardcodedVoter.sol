// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import {IVotingSnapshot} from "../interfaces/oxd/IVotingSnapshot.sol";

contract HardcodedVoter {

  // The account that can undo the voting
  address public immutable  governance;

  // The strategy that is delegating to us
  address public immutable  strategy;

  // Contract we vote on
  IVotingSnapshot constant VOTING_SNAPSHOT = IVotingSnapshot(0xDA007a39a692B0feFe9c6cb1a185feAb2722c4fD);

  // Pool we're voting for
  address constant POOL =  0x6519546433dCB0a34A0De908e1032c46906EF664; // Volatile OXD / bveOXD 

  constructor(address newGovernance, address newStrategy) {
    governance = newGovernance;
    strategy = newStrategy;
  }

  /// @dev Casts vote to target contract
  /// @notice Can be called by anyone as our votes are hardcoded
  /// @notice For user security, check how delegation is handled at the strategy level
  function vote() external {
    // Get Total Votes we got
    int256 totalVotes = int256(VOTING_SNAPSHOT.voteWeightTotalByAccount(strategy));

    // NOTE: If you had multiple pools this is where you can split by ratios
    // NOTE: Not needed in this version

    // Vote
    VOTING_SNAPSHOT.vote(strategy, POOL, totalVotes);
  }

  /// @dev Undoes the vote
  /// @notice Can be called by gov exclusively
  /// @notice To be used before migrating delegate
  function undoVote() external {
    require(msg.sender == governance);

    // Vote
    VOTING_SNAPSHOT.vote(strategy, POOL, 0);
  }
}