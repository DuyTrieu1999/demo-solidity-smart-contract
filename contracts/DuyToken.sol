// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./utils/Set.sol";

contract DuyToken is ERC20, Ownable{
  uint256 internal _maxSupplies; 

  // investor penalty percentage
  mapping(uint256 => uint256) private investorPenaltyPercentage;

  // investor address set
  Set private _investorSet;
  mapping(address => uint256[]) private _investorAddTime;

  constructor() ERC20("Duy Token", "DTK") {
    _mint(msg.sender, 20000000 * (10 ** 18));
    _maxSupplies = 200000000;

    // setup investor penalty
    investorPenaltyPercentage[0 seconds] = 50;
    investorPenaltyPercentage[7257600 seconds] = 25;
    investorPenaltyPercentage[14515200 seconds] = 12;
    investorPenaltyPercentage[29030400 seconds] = 0;
  }

  function _mintDuyToken(address account, uint256 amount) public onlyOwner {
    if (totalSupply() + amount > _maxSupplies) {
      _mint(account, _maxSupplies - totalSupply());
    } else {
      _mint(account, amount);
    }
  }

  function _burnDuyToken(address account, uint256 amount) public onlyOwner {
    _burn(account, amount);
  }

  function transferFrom(
    address from, 
    address to, 
    uint256 amount) public virtual override returns (bool) {
      if (_investorSet.inArray(from)) {
        uint timeDifference = SafeMath.sub(block.timestamp, _investorAddTime[from][0]);
        uint burnAmount = 0;
        if (timeDifference < 7257600 seconds) {
          burnAmount = amount * investorPenaltyPercentage[0 seconds] / 100;
        } else if (timeDifference >= 7257600 seconds && timeDifference < 14515200 seconds) {
          burnAmount = amount * investorPenaltyPercentage[7257600 seconds] / 100;
        } else if (timeDifference >= 14515200 seconds && timeDifference < 29030400 seconds) {
          burnAmount = amount * investorPenaltyPercentage[14515200 seconds] / 100;
        } else {
          burnAmount = 0;
        }
        uint remainingAmount = amount - burnAmount;
        _burn(from, burnAmount);
        transferFrom(from, to, remainingAmount);
      } else {
        transferFrom(from, to, amount);
      }
    }

  function addInvestorList(address _investorAddress) public onlyOwner {
    _investorSet.addToArray(_investorAddress);
    _investorAddTime[_investorAddress].push(block.timestamp);
  }
}