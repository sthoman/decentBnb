//jshint ignore: start

// contracts
const Property = artifacts.require("./Property.sol");
const PropertyCoin = artifacts.require("./PropertyCoin.sol");
const PropertyRegistry = artifacts.require("./PropertyRegistry.sol");

contract('Property Contract Tests', function() {
  it('should be deployed, Property', async () => {
    property = await Property.deployed()
    assert(property !== undefined, 'Property deployment failed')
  });
});

contract('PropertyCoin Contract Tests', function() {
  it('should be deployede, PropertyCoin', async () => {
    propertyCoin = await PropertyCoin.deployed()
    assert(propertyCoin !== undefined, 'PropertyCoin deployment failed')
  });
});

contract('PropertyRegistry Contract Tests', accounts => {

  bob = accounts[0];
  alice = accounts[1];

  it('should be able to create a property, Property', async () => {
    try{
      const tx = await property.createProperty();
    } catch(e) {
      assert(false, 'could not create property')
    }
    assert(true, 'could not create a property')
  });
  it('should be deployed, PropertyRegistry', async () => {
    propertyRegistry = await PropertyRegistry.deployed()
    assert(propertyRegistry !== undefined, 'PropertyRegistry deployment failed')
  });
  //it('should be able to register a property, PropertyRegistry', async () => {
  //  await PropertyRegistry.registerProperty(1, 100000, 'https://');
  //  assert(propertyRegistry.propertyDetails.length == 1, 'PropertyRegistry received registration for a new property')
  //});
  it('should take a request from Bob, PropertyRegistry', async () => {
    await propertyRegistry.registerProperty(1, 100000, 'https://');
  //  await propertyRegistry.requestStay(property.address, { from: bob });
  //// TODO:   assert(propertyRegistry.propertyDetails[1].requested, 'PropertyRegistry took a request from Bob')
  });
});
