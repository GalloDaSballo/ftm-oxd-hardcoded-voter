import brownie
from brownie import *
from dotmap import DotMap
import pytest

def test_basic(snapshot, deployer, setup_voter, rando, locker, token):
  ## Delegation was successful
  assert snapshot.voteDelegateByAccount(deployer) == setup_voter

  ### CAST A VOTE ###
  ## We vote
  setup_voter.vote({"from": rando})

  first_votes = snapshot.votesByAccount(deployer)

  assert len(first_votes) == 1 ## We have 1 vote

  ## Voting twice does nothing
  setup_voter.vote({"from": rando})

  assert len(snapshot.votesByAccount(deployer)) == len(first_votes) ## Same length

  ### VOTE REMOVAL ###
  setup_voter.undoVote({"from": deployer})

  assert len(snapshot.votesByAccount(deployer)) == 0 ## Votes are gone

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
  
