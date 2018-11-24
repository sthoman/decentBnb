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
    uint256 stays;
    address requested;
    address approved;
    address occupant;
    uint256 checkIn;
    uint256 checkOut;
    string uri;
  }

  // Mapping from the _tokenId of the NFT to data about the property
  mapping(uint256 => Data) propertyDetails;

  // Events
  event Approved(uint256 indexed _tokenId);
  event Requested(uint256 indexed _tokenId);
  event Registered(uint256 indexed _tokenId);
  event CheckIn(uint256 indexed _tokenId);
  event CheckOut(uint256 indexed _tokenId);

  // Constructor
  constructor(address _propertyContract, address _propertyToken) public {
    propertyContract = ERC721Basic(_propertyContract);
    propertyToken = ERC20(_propertyToken);
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
  function getPropertyDetailsRequested(uint256 _tokenId) public view returns (address) {
    return propertyDetails[_tokenId].requested;
  }

  /**
   * @dev Gets the details of a property based on its NFT
   * @param _tokenId uint256 ID of the token to query
   * @return structure containing the extended data about the property
   */
  function getStayData(uint256 _tokenId) external view returns(uint256, uint256, address, address, address, uint256, uint256) {
    return (
      propertyDetails[_tokenId].price,
      propertyDetails[_tokenId].stays,
      propertyDetails[_tokenId].requested,
      propertyDetails[_tokenId].approved,
      propertyDetails[_tokenId].occupant,
      propertyDetails[_tokenId].checkIn,
      propertyDetails[_tokenId].checkOut
    );
  }

  /**
   * @dev Registers a new property NFT as a property in this contract
   * @param _tokenId uint256 ID of the NFT
   * @param _price price of the property
   * @param _uri uri of the property
   */
  function registerProperty(uint256 _tokenId, uint256 _price, string _uri) public onlyOwner(_tokenId) {
    propertyDetails[_tokenId] = Data(_price, 0, address(0), address(0), address(0), 0, 0, _uri);
    emit Registered(_tokenId);
  }

  /**
   * @dev Request to stay in a particular property
   * @param _tokenId uint256 ID of the NFT
   */
  function requestStay(uint256 _tokenId) public notRequested(_tokenId) {
    propertyDetails[_tokenId].requested = msg.sender;
    emit Requested(_tokenId);
  }

  /**
   * @dev Approve a request to stay in a particular property
   * @param _tokenId uint256 ID of the NFT
   */
  function approveRequest(uint256 _tokenId) public onlyOwner(_tokenId) {
    propertyDetails[_tokenId].approved = propertyDetails[_tokenId].requested;
    emit Approved(_tokenId);
  }

  /**
   * @dev Check into a particular property
   * @param _tokenId uint256 ID of the NFT
   */
   function checkIn(uint256 _tokenId) external {
     require(propertyDetails[_tokenId].approved == msg.sender);
     require(now > propertyDetails[_tokenId].checkIn);
     //REQUIRED: transfer tokens to propertyRegistry upon successful check in
     //the message sender should have approved the propertyRegistry to transfer
     //at least stayData[_tokenId].price tokens
     //address(this) == this contract address
     require(propertyToken.transferFrom(msg.sender, address(this), propertyDetails[_tokenId].price));
     //move approved guest to occupant
     propertyDetails[_tokenId].occupant = propertyDetails[_tokenId].approved;
     emit CheckIn(_tokenId);
   }

  /**
   * @dev Check out of a particular property
   * @param _tokenId uint256 ID of the NFT
   */
   function checkOut(uint256 _tokenId) external {
     require(propertyDetails[_tokenId].occupant == msg.sender);
     require(now < propertyDetails[_tokenId].checkOut);
     //REQUIRED: transfer tokens to Alice upon successful check out
     require(propertyToken.transfer(propertyContract.ownerOf(_tokenId), propertyDetails[_tokenId].price));
     //clear the request to let another guest request
     propertyDetails[_tokenId].requested = address(0);
     propertyDetails[_tokenId].stays++;
     emit CheckOut(_tokenId);
   }
}
