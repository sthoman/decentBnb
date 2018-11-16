var Property = artifacts.require("./Property.sol");
var PropertyCoin = artifacts.require("./PropertyCoin.sol");
var PropertyRegistry = artifacts.require("./PropertyRegistry.sol");

module.exports = function(deployer) {
    deployer.deploy(PropertyCoin);
    deployer.deploy(Property, 'Property', 'PROP');
    deployer.deploy(PropertyRegistry, '');
};
