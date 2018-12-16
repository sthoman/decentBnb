const Property = artifacts.require("./Property.sol");
const PropertyTenant = artifacts.require("./PropertyTenant.sol");
const PropertyToken = artifacts.require("./PropertyToken.sol");
const PropertyRegistry = artifacts.require("./PropertyRegistry.sol");

contract('PropertyRegistry Contract Tests', accounts => {

  landlord = accounts[0];   // property owner
  alice = accounts[1];      // property lessee (aka tenant)
  bob = accounts[2];        // property sublessor (aka Airbnb user)
  registry_address = '';
  contract_address = '';
  tenant_address = '';
  token_address = '';
  allocation = 10000;
  price = 1000;
  token_NFT = undefined;
  tenancy_NFT = undefined;
  _propertyToken = undefined;
  _propertyRegistry = undefined;
  _propertyTenantContract = undefined;

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
      const tx = await _property.createProperty({ from: landlord });
      token_NFT = await _property.tokenOfOwnerByIndex(landlord, 0);
      token_NFT = token_NFT.c[0];
    } catch(e) {
      assert(false, 'could not create a property');
    }
    assert(true, 'could create a property');
  });

  it('should be deployed, PropertyTenant', async () => {
    propertyTenant = await PropertyTenant.deployed()
    tenant_address = propertyTenant.address;
    assert(propertyTenant !== undefined, 'PropertyTenant deployment failed')
  });

  it('should be able to create a tenant token, PropertyTenant', async () => {
    _propertyTenantContract = await PropertyTenant.at(tenant_address);
    try {
      const tx = await _propertyTenantContract.createTenancyRight({ from: landlord });
      tenancy_NFT = await _propertyTenantContract.tokenOfOwnerByIndex(landlord, 0);
      tenancy_NFT = tenancy_NFT.c[0];
    } catch(e) {
      assert(false, 'could not create tenancy rights to property');
    }
    assert(true, 'could not create tenancy rights to property');
  });

  it('should be deployed, PropertyRegistry', async () => {
    let tx = await PropertyRegistry.deployed();
    registry_address = tx.address;
    assert(registry_address !== undefined, 'PropertyRegistry deployment failed')
  });

  //  Only the landlord can authorize the primary tenant to lease the property
  //  to a subtenant. This is an implicit requirement of an Airbnb-like platform
  //  in any jurisdiction so within this exercise a non-fungible token represents
  //  the tenancy rights, and that token is additionally transferred to the tenant
  //  at the time of registering the property
  //
  it('should be able to register a property and tenancy rights, PropertyRegistry', async () => {
    _propertyRegistry = await PropertyRegistry.at(registry_address);
    await _propertyRegistry.registerProperty(token_NFT, { from: landlord });
    await _propertyRegistry.registerTenancyRights(token_NFT, tenancy_NFT, price, alice, { from: landlord });
    assert(_propertyRegistry.getStayData(token_NFT) !== undefined, 'PropertyRegistry registration failed');
  });

  it('should allow bob to approve the property registry to use his tokens', async () => {
    const tx = await _propertyToken.approve(_propertyRegistry.address, price, { from: bob });
    assert(tx !== undefined, 'property has not been approved');
  });

  //  Tests main workflow -
  //  Bob requests to stay at the property, Alice approves Bob's
  //  request, and Bob checks in. Each time check the stay data
  //  to ensure the addresses are updating correctly.
  //
  it('should take a request from Bob, PropertyRegistry', async () => {
    let awaitRequest = await _propertyRegistry.requestStay(token_NFT, 1, 5, { from: bob });
    let propDetails = await _propertyRegistry.getStayData(token_NFT);
    assert(propDetails[2] === bob, 'PropertyRegistry took a request from Bob');
  });

  it('should allow Alice to approve Bob for check in, PropertyRegistry', async () => {
    let awaitApproval = await _propertyRegistry.approveRequest(token_NFT, tenancy_NFT, { from: alice });
    let propDetails = await _propertyRegistry.getStayData(token_NFT);
    assert(propDetails[3] === bob, 'PropertyRegistry allowed Alice to approve Bobs request');
    assert(propDetails[2] !== bob, 'PropertyRegistry allowed Alice to approve Bobs request');
  });

  it('should allow Bob to check in, PropertyRegistry', async () => {
    let awaitCheckin = await _propertyRegistry.checkIn(token_NFT, { from: bob });
    let propDetails = await _propertyRegistry.getStayData(token_NFT);
    assert(propDetails[4] === bob, 'PropertyRegistry allowed Bob to check in');
    assert(propDetails[3] !== bob, 'PropertyRegistry allowed Bob to check in');
  });

  it('should allow Bob to check out, transferring escrowed funds to Alice, PropertyRegistry', async () => {
    let awaitCheckOut = await _propertyRegistry.checkOut(token_NFT, { from: bob });
    let propDetails = await _propertyRegistry.getStayData(token_NFT);
    let balanceAlice = await _propertyToken.balanceOf.call(alice);
    console.log(balanceAlice+" is bal");
    assert(propDetails[4] !== bob, 'PropertyRegistry allowed Bob to check out and transferred funds to Alice');
    assert(balanceAlice == price, 'PropertyRegistry allowed Bob to check out and transferred funds to Alice');
  });

});
