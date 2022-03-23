from brownie import *
from dotmap import DotMap
import pytest

OXD = "0xc5A9848b9d145965d821AaeC8fA32aaEE026492d"
WHALE = "0xcb6eab779780c7fd6d014ab90d8b10e97a1227e2"
LOCKER = "0xDA00527EDAabCe6F97D89aDb10395f719E5559b9"
VOTING_SNAPSHOT = "0xDA007a39a692B0feFe9c6cb1a185feAb2722c4fD"

@pytest.fixture
def deployer():
    return accounts[0]

@pytest.fixture
def user():
    return accounts[1]

@pytest.fixture
def rando():
    return accounts[6]

@pytest.fixture
def locker():
    return interface.IVlOxd(LOCKER)

@pytest.fixture
def snapshot():
    return interface.IVotingSnapshot(VOTING_SNAPSHOT)

@pytest.fixture
def voter(deployer):
    return HardcodedVoter.deploy(deployer, deployer, {"from": deployer})


@pytest.fixture
def setup_voter(locker, deployer, voter, snapshot):
    amount = 10000e18

    ## Get oxd
    token = interface.ERC20(OXD)
    whale = accounts.at(WHALE, force=True)
    token.transfer(deployer, amount, {"from": whale})

    ## Lock oxd
    token.approve(locker, amount, {"from": deployer})
    locker.lock(deployer, amount, 0, {"from": deployer})

    ## Delegate to Voter
    snapshot.setVoteDelegate(voter, {"from": deployer})

    return voter

## Forces reset before each test
@pytest.fixture(autouse=True)
def isolation(fn_isolation):
    pass


