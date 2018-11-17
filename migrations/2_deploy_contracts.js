var Property = artifacts.require("./Property.sol");
var PropertyCoin = artifacts.require("./PropertyCoin.sol");
var PropertyRegistry = artifacts.require("./PropertyRegistry.sol");

module.exports = function(deployer) {
    deployer.deploy(Property, 'Property', 'PROP').then(
      () => {
        deployer.deploy(PropertyCoin);
        deployer.deploy(PropertyRegistry, Property.address);
    });
};
