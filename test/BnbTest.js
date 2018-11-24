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
  token_NFT = undefined;
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
      const tx = await _property.createProperty({ from: alice });
      token_NFT = await property.tokenOfOwnerByIndex(alice, 0);
      token_NFT = token_NFT.c[0];
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
    await _propertyRegistry.registerProperty(token_NFT, 1000, 'https://', { from: alice });
    assert(_propertyRegistry.getStayData(token_NFT) !== undefined, 'PropertyRegistry registration failed');
  });

  it('should allow alice to approve the property registry to use his tokens', async () => {
    const tx = await _propertyToken.approve(_propertyRegistry.address, 1000, { from: bob });
    assert(tx !== undefined, 'property has not been approved');
  });

  it('should take a request from Bob, PropertyRegistry', async () => {
    let awaitRequest = await _propertyRegistry.requestStay(token_NFT, { from: bob });
    let propDetails = await _propertyRegistry.getStayData(token_NFT);
    assert(propDetails[2] === bob, 'PropertyRegistry took a request from Bob')
  });

});
