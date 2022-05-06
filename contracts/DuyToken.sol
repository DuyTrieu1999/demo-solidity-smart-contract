// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DuyToken is ERC20, Ownable{
  uint256 internal _maxSupplies; 


  constructor() ERC20("Duy Token", "DTK") {
    _mint(msg.sender, 20000000 * (10 ** 18));
    _maxSupplies = 200000000;
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
}