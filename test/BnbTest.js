const Property = artifacts.require("./Property.sol");
const PropertyToken = artifacts.require("./PropertyToken.sol");
const PropertyRegistry = artifacts.require("./PropertyRegistry.sol");

contract('PropertyRegistry Contract Tests', accounts => {

  alice = accounts[0];
  bob = accounts[1];
  registry_address = '';
  contract_address = '';
  token_address = '';
  allocation = 10000;
  _propertyToken = undefined;
  _propertyRegistry = undefined;

  it('should be deployed, PropertyToken', async () => {
    _propertyToken = await PropertyToken.deployed()
    token_address = _propertyToken.address;
    assert(_propertyToken !== undefined, 'PropertyToken deployment failed')
  });

  it('should be able to mint, PropertyToken', async () => {
    const tx = await _propertyToken.mint(bob, allocation);
    const balance = await _propertyToken.balanceOf.call(bob);
    assert.equal(balance.toNumber(), allocation, 'balance');
  });

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

  it('should allow bob to approve the property registry to use his tokens', async () => {
    const tx = await _propertyToken.approve(_propertyRegistry.address, 1000, { from: bob });
    console.log(tx);
    assert(tx !== undefined, 'property has not been approved');
  });

/*
  it('should take a request from Bob, PropertyRegistry', async () => {
    await _propertyRegistry.requestStay(property.address, { from: bob });
    assert(_propertyRegistry.propertyDetails.length == 1, 'PropertyRegistry took a request from Bob')
  });
*/

});
