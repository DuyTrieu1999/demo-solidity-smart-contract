// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../DuyToken.sol";

contract NFT is ERC721URIStorage, Ownable {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  DuyToken public token;
  mapping(uint256 => address) private _creators;

  event Sale(address from, address to, uint256 value);

  constructor(DuyToken _token) ERC721("MyToken", "MTK") {
    token = _token;
  }

  // minting requires creator address so we can specify which brand creates this NFT
  function safeMint(address creator, address to, string memory tokenURI) public onlyOwner {
    _tokenIds.increment();
    uint256 newTokenId = _tokenIds.current();
    _creators[newTokenId] = creator;
    // minting fee of 50 Sway
    token.transferFrom(to, address(this), 50);
    _safeMint(to, newTokenId);
    _setTokenURI(newTokenId, tokenURI);
  }

  function transferFrom(
    address from, 
    address to, 
    uint256 tokenId
  ) public virtual override(ERC721) {
    require(from != address(0x0), 'invalid from address');
    require(to != address(0x0), 'invalid to address');

    require(tokenId > 0, 'invalid tokenId');
    require(tokenId <= _tokenIds.current(), 'invalid tokenId');

    _payRoyalty(tokenId, from, to);

    _transfer(from, to, tokenId);
  }

  function safeTransferFrom(
    address from, 
    address to, 
    uint256 tokenId
  ) public virtual override(ERC721) {
    require(from != address(0x0), 'invalid from address');
    require(to != address(0x0), 'invalid to address');

    require(tokenId > 0, 'invalid tokenId');
    require(tokenId <= _tokenIds.current(), 'invalid tokenId');

    _payRoyalty(tokenId, from, to);

    safeTransferFrom(from, to, tokenId, "");
  }

  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId,
    bytes memory _data
  ) public virtual override {
    require(from != address(0x0), 'invalid from address');
    require(to != address(0x0), 'invalid to address');

    require(tokenId > 0, 'invalid tokenId');
    require(tokenId <= _tokenIds.current(), 'invalid tokenId');

    _payRoyalty(tokenId, from, to);

    _safeTransfer(from, to, tokenId, _data);
  }

  // pay not in Duy token
  function _payRoyalty(uint256 tokenId, address from, address to) internal {
    if (msg.value > 0) {
      uint256 royalty = (msg.value * 3) / 100;
      (bool success1, ) = payable(_creators[tokenId]).call{value: royalty}("");
      require(success1);

      (bool success2, ) = payable(from).call{value: msg.value - royalty}("");
      require(success2);

      emit Sale(from, to, msg.value);
    }
  }

  function _beforeTokenTransfer(address from, address to, uint256 tokenId)
    internal
    override(ERC721) {
      super._beforeTokenTransfer(from, to, tokenId);
  }

  function supportsInterface(bytes4 interfaceId)
    public
    view 
    override(ERC721)
    returns (bool) {
      return super.supportsInterface(interfaceId);
  }
}