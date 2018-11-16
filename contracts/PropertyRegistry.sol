pragma solidity ^0.4.24;

import '../node_modules/zeppelin-solidity/contracts/token/ERC20/ERC20.sol';
import '../node_modules/zeppelin-solidity/contracts/token/ERC721/ERC721Basic.sol';

contract PropertyRegistry {

  ERC20 propertyToken;        // utility token to transact for properties
  ERC721Basic propertyContract;    // contract facilitating multiple property NFTs

  struct Data {
    uint256 price;
    address requested;
    address approved;
    address occupant;
    uint256 checkIn;
    uint256 checkOut;
    string uri;
  }

  mapping(uint256 => Data) propertyDetails;

  constructor(address _propertyContract) public {
    propertyContract = ERC721Basic(_propertyContract);
  }

  modifier onlyOwner(uint256 _tokenId) {
    require(msg.sender == propertyContract.ownerOf(_tokenId));
    _;
  }

  modifier notRequested(uint256 _tokenId) {
    require(address(0) == propertyDetails[_tokenId].requested);
    _;
  }

  function getPropertyDetails(uint256 _tokenId) public view returns(uint256, address, string) {
    return (
      propertyDetails[_tokenId].price,
      propertyDetails[_tokenId].occupant,
      propertyDetails[_tokenId].uri
    );
  }

  function registerProperty(uint256 _tokenId, uint256 _price, string _uri) public onlyOwner(_tokenId) {
    propertyDetails[_tokenId] = Data(_price, address(0), address(0), address(0), 0, 0, _uri);
  }

  function requestStay(uint256 _tokenId) public notRequested(_tokenId) {
    propertyDetails[_tokenId].requested = msg.sender;
  //  propertyDetails[_tokenId].checkIn = _checkIn;   ///TODO
  //  propertyDetails[_tokenId].checkOut = _checkOut;
  }

  function approveRequest(uint256 _tokenId) public onlyOwner(_tokenId) {
    propertyDetails[_tokenId].approved = propertyDetails[_tokenId].requested;
  }

  function checkIn(uint _tokenId) public {
    require(propertyDetails[_tokenId].approved == msg.sender);
    require(now > propertyDetails[_tokenId].checkIn);
    propertyDetails[_tokenId].occupant = msg.sender;
  }

  function checkOut(uint _tokenId) public {
    require(propertyDetails[_tokenId].occupant == msg.sender);
    propertyDetails[_tokenId].requested = address(0);
  //  propertyDetails[_tokenId]
  }
}
