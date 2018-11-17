pragma solidity ^0.4.24;

import '../node_modules/zeppelin-solidity/contracts/token/ERC20/ERC20.sol';
import '../node_modules/zeppelin-solidity/contracts/token/ERC721/ERC721Basic.sol';

/**
 * @title PropertyRegistry Registry pattern for properties driven by the Non-Fungible Token Standard
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract PropertyRegistry {

  // A utility token to transact for properties in decentralized
  // airbnb and a contract facilitating multiple property NFTs
  ERC20 propertyToken;
  ERC721Basic propertyContract;

  // Storage data relevant to the property, the addresses of it's
  // occupant and requested occupant, and URI containing metadata
  struct Data {
    uint256 price;
    address requested;
    address approved;
    address occupant;
    uint256 checkIn;
    uint256 checkOut;
    string uri;
  }

  // Mapping from the _tokenId of the NFT to data about the property
  mapping(uint256 => Data) propertyDetails;

  // Constructor
  constructor(address _propertyContract) public {
    propertyContract = ERC721Basic(_propertyContract);
  }

  // Modifier to validate only the owner of the NFT
  modifier onlyOwner(uint256 _tokenId) {
    require(msg.sender == propertyContract.ownerOf(_tokenId));
    _;
  }

  // Modifier to validate that no one is waiting to occupy the property
  modifier notRequested(uint256 _tokenId) {
    require(address(0) == propertyDetails[_tokenId].requested);
    _;
  }

  /**
   * @dev Gets the details of a property based on its NFT
   * @param _tokenId uint256 ID of the token to query
   * @return structure containing the extended data about the property
   */
  function getPropertyDetails(uint256 _tokenId) public view returns(uint256, address, string) {
    return (
      propertyDetails[_tokenId].price,
      propertyDetails[_tokenId].occupant,
      propertyDetails[_tokenId].uri
    );
  }

  /**
   * @dev Registers a new property NFT as a property in this contract
   * @param _tokenId uint256 ID of the NFT
   * @param _price price of the property
   * @param _uri uri of the property
   */
  function registerProperty(uint256 _tokenId, uint256 _price, string _uri) public onlyOwner(_tokenId) {
    propertyDetails[_tokenId] = Data(_price, address(0), address(0), address(0), 0, 0, _uri);
  }

  /**
   * @dev Request to stay in a particular property
   * @param _tokenId uint256 ID of the NFT
   */
  function requestStay(uint256 _tokenId) public notRequested(_tokenId) {
    propertyDetails[_tokenId].requested = msg.sender;
  }

  /**
   * @dev Approve a request to stay in a particular property
   * @param _tokenId uint256 ID of the NFT
   */
  function approveRequest(uint256 _tokenId) public onlyOwner(_tokenId) {
    propertyDetails[_tokenId].approved = propertyDetails[_tokenId].requested;
  }

  /**
   * @dev Check into a particular property
   * @param _tokenId uint256 ID of the NFT
   */
  function checkIn(uint _tokenId) public {
    require(propertyDetails[_tokenId].approved == msg.sender);
    require(now > propertyDetails[_tokenId].checkIn);
    propertyDetails[_tokenId].occupant = msg.sender;
  }

  /**
   * @dev Check out of a particular property
   * @param _tokenId uint256 ID of the NFT
   */
  function checkOut(uint _tokenId) public {
    require(propertyDetails[_tokenId].occupant == msg.sender);
    propertyDetails[_tokenId].requested = address(0);
  }
}
