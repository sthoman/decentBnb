const Property = artifacts.require("./Property.sol");
const PropertyToken = artifacts.require("./PropertyToken.sol");
const PropertyRegistry = artifacts.require("./PropertyRegistry.sol");

/*
contract('PropertyCoin Contract Tests', function() {
  it('should be deployed, PropertyCoin', async () => {
    propertyCoin = await PropertyCoin.deployed()
    assert(propertyCoin !== undefined, 'PropertyCoin deployment failed')
  });
});
*/
contract('PropertyRegistry Contract Tests', accounts => {

  bob = accounts[0];
  alice = accounts[1];
  registry_address = '';
  contract_address = '';
  _propertyRegistry = undefined;

  it('should be deployed, Property', async () => {
    property = await Property.deployed()
    contract_address = property.address;
    assert(property !== undefined, 'Property deployment failed')
  });

  it('should be able to create a property, Property', async () => {
    let _property = await Property.at(contract_address);
    try {
      const tx = await _property.createProperty();
    } catch(e) {
      assert(false, 'could not create a property');
    }
    assert(true, 'could create a property');
  });

  it('should be deployed, PropertyRegistry', async () => {
    let tx = await PropertyRegistry.deployed();
    registry_address = tx.address;
    assert(registry_address !== undefined, 'PropertyRegistry deployment failed')
  });

  it('should be able to register a property, PropertyRegistry', async () => {
    _propertyRegistry = await PropertyRegistry.at(registry_address);
    await _propertyRegistry.registerProperty(1, 100000, 'https://');
    assert(_propertyRegistry.propertyDetails !== undefined, 'PropertyRegistry registration failed');
  });
/*
  it('should take a request from Bob, PropertyRegistry', async () => {
    await _propertyRegistry.requestStay(property.address, { from: bob });
    assert(_propertyRegistry.propertyDetails.length == 1, 'PropertyRegistry took a request from Bob')
  });
*/
});
