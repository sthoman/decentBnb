pragma solidity ^0.4.24;

import '../node_modules/openzeppelin-solidity/contracts/token/ERC20/ERC20.sol';
import '../node_modules/openzeppelin-solidity/contracts/token/ERC721/ERC721Basic.sol';

/**
 * @title PropertyRegistry Registry pattern for properties driven by the Non-Fungible Token Standard
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract PropertyRegistry {

  // A utility token to transact for properties in decentralized
  // airbnb and a contract facilitating multiple property NFTs
  ERC20 propertyToken;
  ERC721Basic propertyContract;
  ERC721Basic propertyTenantContract;

  // Storage data relevant to the property, the addresses of it's
  // occupant and requested occupant, and URI containing metadata
  struct Data {
    uint256 price;
    uint256 stays;
    address lessee;
    address requested;
    address approved;
    address occupant;
    uint256 checkIn;
    uint256 checkOut;
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
  constructor(address _propertyContract, address _propertyTenantContract, address _propertyToken) public {
    propertyContract = ERC721Basic(_propertyContract);
    propertyTenantContract = ERC721Basic(_propertyTenantContract);
    propertyToken = ERC20(_propertyToken);
  }

  // Modifier to validate only the owner of the NFT
  modifier onlyOwner(uint256 _tokenId) {
    require(msg.sender == propertyContract.ownerOf(_tokenId));
    _;
  }

  // Modifier to validate only the tenant of the NFT
  modifier onlyTenant(uint256 _tokenId) {
    require(msg.sender == propertyTenantContract.ownerOf(_tokenId));
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
   * @param _ownershipTokenId uint256 ID of the NFT
   */
  function registerProperty(uint256 _ownershipTokenId) public onlyOwner(_ownershipTokenId) {
    propertyDetails[_ownershipTokenId] = Data(0, 0, address(0), address(0), address(0), address(0), 0, 0);
    emit Registered(_ownershipTokenId);
  }

  /**
   * @dev Registers a new lessee NFT as the tenant of the property with rights to sublet the property
   * @param _ownershipTokenId uint256 ID of the NFT
   * @param _lessee address of the lessee / tenant
   */
  function registerTenancyRights(uint256 _ownershipTokenId, uint256 _tenancyTokenId, uint256 _price, address _lessee) public onlyOwner(_ownershipTokenId) {
    // REQUIRED: no one can already be leasing the property, and the landlord must
    // transfer ownership of the NFT that represents tenancy rights to the tenant,
    // which includes the right to sublet in this limited use case (for the time being)
    //
    require(propertyDetails[_ownershipTokenId].lessee == address(0));
    require(propertyTenantContract.ownerOf(_tenancyTokenId) == msg.sender);
    propertyTenantContract.setApprovalForAll(_lessee, true);
    propertyTenantContract.approve(_lessee, _tenancyTokenId); 
    ////TODO how to approve just for _lessee?
  //  require(propertyTenantContract.getApproved(_tenancyTokenId) == msg.sender);
  //  propertyTenantContract.setApprovalForAll(msg.sender, true);  ////TODO how to approve just for _lessee?
  //  propertyTenantContract.transferFrom(msg.sender, _lessee, _tenancyTokenId);
    propertyDetails[_ownershipTokenId].lessee = _lessee;
    propertyDetails[_ownershipTokenId].price = _price;//TODO num of params problem
  //TODO  emit Registered(_tokenId);
  }

  /**
   * @dev Request to stay in a particular property
   * @param _tokenId uint256 ID of the NFT
   */
  function requestStay(uint256 _tokenId, uint256 _checkIn, uint256 _checkOut) public notRequested(_tokenId) {
    propertyDetails[_tokenId].requested = msg.sender;
    propertyDetails[_tokenId].checkIn = _checkIn;
    propertyDetails[_tokenId].checkOut = _checkOut;
    emit Requested(_tokenId);
  }

  /**
   * @dev Approve a request to stay in a particular property. Allow another guest to queue in line as a request.
   * @param _propertyTokenId uint256 ID of the NFT that represents the tenancy rights
   */
  function approveRequest(uint256 _propertyTokenId, uint256 _tenancyTokenId) public onlyTenant(_tenancyTokenId) {
    //REQUIRED: approver explicitly approves the check in / check out date ??
    //require(propertyDetails[_propertyTokenId].checkIn == _checkIn);
    propertyDetails[_propertyTokenId].approved = propertyDetails[_propertyTokenId].requested;
    propertyDetails[_propertyTokenId].requested = address(0);
    emit Approved(_propertyTokenId);
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
     //at least stayData[_tokenId].price tokens and these funds remain in
     //escrow inside this PropertyRegistry contract
     require(propertyToken.transferFrom(msg.sender, address(this), propertyDetails[_tokenId].price));
     //move approved guest to occupant, reset the approved guest
     propertyDetails[_tokenId].occupant = msg.sender;
     propertyDetails[_tokenId].approved = address(0);
     emit CheckIn(_tokenId);
   }

  /**
   * @dev Check out of a particular property
   * @param _tokenId uint256 ID of the NFT
   */
   function checkOut(uint256 _tokenId) external {
     require(propertyDetails[_tokenId].occupant == msg.sender);
     //TODO: investigate time types //require(now < propertyDetails[_tokenId].checkOut);
     //REQUIRED: transfer tokens to Alice upon successful check out
     require(propertyToken.transfer(propertyContract.ownerOf(_tokenId), propertyDetails[_tokenId].price));
     //clear the occupant
     propertyDetails[_tokenId].occupant = address(0);
     propertyDetails[_tokenId].stays++;
     emit CheckOut(_tokenId);
   }
}
