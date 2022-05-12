// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/ownership/Ownable.sol";
import "./DuyToken.sol";

contract Vouch is Ownable {
  DuyToken public token;
  address[] internal _stakeholders;
  mapping(address => uint256) internal _stakes;
  mapping(address => uint256) internal _rewards;
  mapping(address => uint256) internal _penalties;

  constructor(
    DuyToken _token
  ) {
    token = _token;
  }

  function isStakeHolder(address _address) public view returns(bool, uint256) {
    for (uint256 s = 0; s < _stakeholders.length; s++) {
      if (_address == _stakeholders[s]) {
        return (true, s);
      }
    }
    return (false, 0);
  }

  function addStakeHolder(address _stakeholder) private {
    (bool _isStakeholder, ) = isStakeHolder(_stakeholder);
    if (!_isStakeholder) {
      _stakeholders.push(_stakeholder);
    }
  }

  function removeStakeHolder(address _stakeholder) private {
    (bool _isStakeholder, uint256 index) = isStakeHolder(_stakeholder); 
    if (_isStakeholder) {
      _stakeholders[index] = _stakeholders[_stakeholders.length - 1];
      _stakeholders.pop();
    }
  }

  function stakeOf(address _stakeholder) public view returns(uint256) {
    return _stakes[_stakeholder];
  }

  function getTotalStakes() public view returns(uint256) {
    uint256 _totalStakes = 0;
    for (uint256 i = 0; i < _stakeholders.length; i++) {
      _totalStakes += (_stakes[_stakeholders[i]]);
    }
    return _totalStakes;
  }

  function createStake(uint256 _stakeAmount) public {
    require(_stakeAmount <= token.balanceOf(msg.sender), "Stake amount has to be less than balance");
    token._burnDuyToken(msg.sender, _stakeAmount);
    if (_stakes[msg.sender] == 0) {
      addStakeHolder(msg.sender);
    }
    _stakes[msg.sender] += _stakeAmount;
  }

  function removeStake(uint256 _stakeAmount) public {
    _stakes[msg.sender] -= _stakeAmount;
    if (_stakes[msg.sender] == 0) {
      removeStakeHolder(msg.sender);
    }
    token._mintDuyToken(msg.sender, _stakeAmount);
  }

  function rewardOf(address _stakeholder) public view returns(uint256) {
    return _rewards[_stakeholder];
  }

  function getTotalReward() public view returns(uint256) {
    uint256 _totalRewards = 0;
    for (uint256 i = 0; i < _stakeholders.length; i++) {
      _totalRewards += (_rewards[_stakeholders[i]]);
    }
    return _totalRewards;
  }

  // need rework based on tokenomics
  function calculateReward(address _stakeholder) private view returns(uint256) {
    return _stakes[_stakeholder] / 100;
  }

  function withdrawReward() public {
    uint256 reward = _rewards[msg.sender];
    _rewards[msg.sender] = 0;
    token._mintDuyToken(msg.sender, reward);
  }

  function distributeRewards() public onlyOwner {
    for (uint256 i = 0; i < _stakeholders.length; i++) {
      address _stakeholder = _stakeholders[i];
      uint reward = calculateReward(_stakeholder);
      _rewards[_stakeholder] += reward;
    }
  }

  function penaltyOf(address _stakeholder) public view returns(uint256) {
    return _penalties[_stakeholder];
  }

  function getTotalPenalties() public view returns(uint256) {
    uint256 _totalPenalties = 0;
    for (uint256 i = 0; i < _stakeholders.length; i++) {
      _totalPenalties += (_penalties[_stakeholders[i]]);
    }
    return _totalPenalties;
  }

  function distributePenalties() public onlyOwner {
    for (uint256 i = 0; i < _stakeholders.length; i++) {
      address _stakeholder = _stakeholders[i];
      uint penalty = _stakes[_stakeholder];
      _penalties[_stakeholder] = penalty;
    }

    for (uint256 i = 0; i < _stakeholders.length; i++) {
      address _stakeholder = _stakeholders[i];
      applyPenalty(_stakeholder);
    }
  }

  // apply penalty and burn staked token
  function applyPenalty(address _account) private {
    uint256 penalty = _penalties[_account];
    _penalties[_account] = 0;
    token._burnDuyToken(_account, penalty);
  }
}