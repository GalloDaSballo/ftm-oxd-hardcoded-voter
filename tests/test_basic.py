import brownie
from brownie import *
from dotmap import DotMap
import pytest

BASE_POOL =  "0x6519546433dCB0a34A0De908e1032c46906EF664"      # Volatile OXD / bveOXD
VAMM_BVEOXD_DAI = "0xB2A931f695DA937e426cf5b71C87CACcDa6db194" # Volatile DEI/ bveOXD

def test_basic(snapshot, deployer, setup_voter, rando, locker, token):
  ## Delegation was successful
  assert snapshot.voteDelegateByAccount(deployer) == setup_voter

  ### CAST A VOTE ###
  ## We vote
  setup_voter.vote({"from": rando})
  total_votes = snapshot.voteWeightTotalByAccount(deployer)
  first_votes = snapshot.votesByAccount(deployer)
  assert total_votes > 0  # our address has votes
  assert len(first_votes) > 0  # we have voted for something

  used_votes = 0
  basepoolChecked = False
  for vote in first_votes:
    used_votes += vote[1]
    if vote[0] == BASE_POOL:
      basepoolChecked = True
      assert vote[1] > total_votes/2  # at least half our vote weight to the base pair
    elif snapshot.weightByPoolSigned(vote[0]) > 0:  #  A matching pool has external votes
      assert vote[1] < snapshot.weightByPoolSigned(vote[0])  # we matched no more than 1/1
      assert vote[1] > 0  # we matched something
  assert basepoolChecked  # We looped over the BVEOXD/OXD pool and asserted it had votes
  assert used_votes == total_votes  # all votes are used
  assert snapshot.voteWeightAvailableByAccount(deployer) == 0 # all votes are used onchain

  ## Voting twice does nothing
  setup_voter.vote({"from": rando})

  assert len(snapshot.votesByAccount(deployer)) == len(first_votes) ## Same length

  ### VOTE REMOVAL ###
  setup_voter.undoVote({"from": deployer})

  assert len(snapshot.votesByAccount(deployer)) == 0 ## Votes are gone
  assert snapshot.voteWeightTotalByAccount(deployer) == snapshot.voteWeightAvailableByAccount(deployer) ## all votes are available

  ### LOCKING MORE ###
  amount = 3690e18

  ## Lock oxd
  token.approve(locker, amount, {"from": deployer})
  locker.lock(deployer, amount, 0, {"from": deployer})

  ## And vote again
  setup_voter.vote({"from": rando})

  new_votes = snapshot.votesByAccount(deployer)

  assert len(new_votes) == len(first_votes) ## Same length

  assert first_votes[0][1] < new_votes[0][1] ## lock is stronger
  
