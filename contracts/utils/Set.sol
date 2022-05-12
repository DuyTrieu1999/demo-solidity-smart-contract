// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Set {
  mapping (address => uint) index;
  address[] store;

  function SimpleSet() public {
    // We will use position 0 to flag invalid address
    store.push(payable(0x0));
  }

  function addToArray(address who) public {
    if (!inArray(who)) {
      // Append
      index[who] = store.length;
      store.push(who);
    }
  }

    function inArray(address who) public view returns (bool) {
      // address 0x0 is not valid if pos is 0 is not in the array
      if (who != address(0x0) && index[who] > 0) {
        return true;
      }
      return false;
    }

    function getPosition(uint pos) public view returns (address) {
      // Position 0 is not valid
      require(pos > 0); 
      return store[pos];
    }
}