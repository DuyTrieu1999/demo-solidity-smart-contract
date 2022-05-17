// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/utils/TokenTimelock.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./DuyToken.sol";

contract TokenCrowdsale is Ownable {
  // Duy token
  DuyToken public token;
  uint256 public totalFunds;
  uint256 public distributedTokens;

  // beneficiaries list
  address[] public beneficiaries;

  // stage for funding
  enum FundingStage { Seed, PreSale, IDO }
  // role: team/advisor or investor
  enum Role { Team, Investor } 

  // project launch date
  uint256 internal projectLaunchDate;

  // token lockup
  uint256 public releaseTime;

  // mapping of beneficiary to token lockup time (only applied to team and advisor)
  mapping(address => TokenTimelock[]) private beneficiaryDistributionContracts;

  event BeneficiaryAdded(
    address indexed beneficiary,
    TokenTimelock timelock,
    uint256 amount
  );

  modifier validAddress(address _address) {
    require(_address != address(0));
    require(_address != address(this));
    _;
  }

  FundingStage public stage = FundingStage.Seed;

  constructor(
    DuyToken _token,
    uint256 _projectLaunchDate,
    uint256 _releaseTime
  ) {
    token = _token;
    totalFunds = _token.totalSupply();
    projectLaunchDate = _projectLaunchDate;
    releaseTime = _releaseTime;
    setup();
  }

  // setup token allocation 
  function setup() private {
    
  }

  // add beneficiary that will be allowed to extract token after the release date
  function addBeneficiary(
    address _beneficiary,
    uint256 _amount
  ) public onlyOwner validAddress(_beneficiary) returns (TokenTimelock) {
    require(_beneficiary != msg.sender);
    require(_amount > 0);
    require(block.timestamp < releaseTime);

    // Check there are sufficient funds and actual token balance.
    require(SafeMath.sub(totalFunds, distributedTokens) >= _amount);
    require(token.balanceOf(address(this)) >= _amount);

    if (!isBeneficiaryExist(_beneficiary)) {
      beneficiaries.push(_beneficiary);
    }
    distributedTokens += _amount;
    TokenTimelock _timeLock = new TokenTimelock(token, _beneficiary, releaseTime);
    token.transfer(_beneficiary, _amount);

    beneficiaryDistributionContracts[_beneficiary].push(_timeLock);


    emit BeneficiaryAdded(_beneficiary, _timeLock, _amount);
    return _timeLock;
  }

  function releaseFunding(address _beneficiary) public onlyOwner validAddress(_beneficiary) {
    if (isBeneficiaryExist(_beneficiary)) {
      beneficiaryDistributionContracts[_beneficiary][0].release();
    }
  }

  // set funding stage
  function setFundingStage(uint _stage) public onlyOwner {
    if (uint(FundingStage.Seed) == _stage) {
      stage = FundingStage.Seed;
    } else if (uint(FundingStage.PreSale) == _stage) {
      stage = FundingStage.PreSale;
    } else if (uint(FundingStage.IDO) == _stage) {
      stage = FundingStage.IDO;
    }
  }

  function isBeneficiaryExist(
    address _beneficiary
  ) internal view returns (bool) {
    return beneficiaryDistributionContracts[_beneficiary].length > 0;
  }
}