import brownie
from brownie import *
from dotmap import DotMap
import pytest

def test_basic(snapshot, deployer, setup_voter, rando):
  ## Delegation was successful
  assert snapshot.voteDelegateByAccount(deployer) == setup_voter

  ## We vote
  setup_voter.vote({"from": rando})

  all_votes = snapshot.votesByAccount(deployer)

  assert len(all_votes) == 1 ## We have 1 vote

  ## Voting twice does nothing
  setup_voter.vote({"from": rando}) ## can't vote twice

  assert len(snapshot.votesByAccount(deployer)) == 1 ## Same length

  setup_voter.undoVote({"from": deployer})

  assert len(snapshot.votesByAccount(deployer)) == 0 ## Votes are gone