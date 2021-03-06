pragma solidity 0.4.24;

import '../node_modules/openzeppelin-solidity/contracts/token/ERC721/ERC721Token.sol';

/**
 * @title Property An NFT to represent the tenant occupying a particular property
 *        Specifically, this NFT represents the right of the tenant to sublet aka
 *        provide the property for temporary use via this decentralized platform
 *
 *

 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract PropertyTenant is ERC721Token {

  constructor(string _name, string _symbol) public ERC721Token(_name, _symbol) {
  }

  modifier onlyOwner(uint256 _tokenId) {
    require(tokenOwner[_tokenId] == msg.sender);
    _;
  }

  function createProperty() external returns(uint256) {
    _mint(msg.sender, allTokens.length + 1);
  }

  function setURI(uint256 _tokenId, string _uri) external onlyOwner(_tokenId) {
    _setTokenURI(_tokenId, _uri);
  }

  function getURI(uint256 _tokenId) external view returns(string) {
    return tokenURIs[_tokenId];
  }

  function getProperties() external view returns(uint256[]) {
    return ownedTokens[msg.sender];
  }
}
