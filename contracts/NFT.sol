// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./DuyToken.sol";

contract NFT is ERC721, ERC2981, ERC721Enumerable, Ownable {
  DuyToken public token;
  string public contractUri;

  constructor(DuyToken _token, uint96 _royaltyFeeInBips, string memory _contractUri) ERC721("MyToken", "MTK") {
    setRoyaltyInfo(owner(), _royaltyFeeInBips);
    contractUri = _contractUri;
    token = _token;
  }

  function setRoyaltyInfo(address _receiver, uint96 _royaltyFeeInBips) public onlyOwner {
    _setDefaultRoyalty(_receiver, _royaltyFeeInBips);
  }

  function safeMint(address to, uint256 tokenId) public onlyOwner {
    // minting fee of 50 Sway
    token.transferFrom(to, address(this), 50);
    _safeMint(to, tokenId);
  }

  function setContractUri(string calldata _contractUri) public onlyOwner {
    contractUri = _contractUri;
  }

  function _beforeTokenTransfer(address from, address to, uint256 tokenId)
    internal
    override(ERC721, ERC721Enumerable) {
      super._beforeTokenTransfer(from, to, tokenId);
  }

  function supportsInterface(bytes4 interfaceId)
    public
    view 
    override(ERC721, ERC721Enumerable, ERC2981)
    returns (bool) {
      return super.supportsInterface(interfaceId);
  }
}