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
  address constant BASE_POOL =  0x6519546433dCB0a34A0De908e1032c46906EF664; // Volatile OXD / bveOXD
  address constant VAMM_BVEOXD_DAI = 0xB2A931f695DA937e426cf5b71C87CACcDa6db194; // Matching agreed with DEUS


  constructor(address newGovernance, address newStrategy) {
    governance = newGovernance;
    strategy = newStrategy;
  }


  /// @dev Casts vote to target contract
  /// @notice Can be called by anyone as our votes are hardcoded
  /// @notice For user security, check how delegation is handled at the strategy level
  function vote() external {
    // Get Total Votes available and set an allocation for matching
    int256 totalVotes = int256(VOTING_SNAPSHOT.voteWeightTotalByAccount(strategy));
    int256 matchingVotes = totalVotes / 2;

    // Reset votes so we don't include ourselves for matching
      VOTING_SNAPSHOT.resetVotes(strategy);

    // Calculate vote matching will need more work if more than one pair to match
    int256 externalVotesForDEI = VOTING_SNAPSHOT.weightByPoolSigned(VAMM_BVEOXD_DAI);
    int256 ourVotesForDEI = externalVotesForDEI >= matchingVotes ? matchingVotes : externalVotesForDEI;
    int256 ourLeftoverVotes = totalVotes - ourVotesForDEI;


    // Vote
    VOTING_SNAPSHOT.vote(strategy, BASE_POOL, ourLeftoverVotes);
    VOTING_SNAPSHOT.vote(strategy, VAMM_BVEOXD_DAI, ourVotesForDEI);
  }

  /// @dev Undoes the vote
  /// @notice Can be called by gov exclusively
  /// @notice To be used before migrating delegate
  function undoVote() external {
    require(msg.sender == governance);

    // Vote
    //VOTING_SNAPSHOT.vote(strategy, BASE_POOL, 0);
    //VOTING_SNAPSHOT.vote(strategy, VAMM_BVEOXD_DAI, 0);
    VOTING_SNAPSHOT.resetVotes(strategy);
  }
}