const property = artifacts.require("./Property.sol");
const propertyTenant = artifacts.require("./PropertyTenant.sol");
const propertyRegistry = artifacts.require("./PropertyRegistry.sol");
const propertyToken = artifacts.require("./PropertyToken.sol");

module.exports = function(deployer) {
    deployer.deploy(property, "Property", "PROP").then(() => {
        return deployer.deploy(propertyTenant, "PropertyTenant", "HOST").then(() => {
           return deployer.deploy(propertyToken, "propertyToken", "BNB", 18).then(() => {
                return deployer.deploy(propertyRegistry, property.address, propertyTenant.address, propertyToken.address)
           })
        })
    })
};
