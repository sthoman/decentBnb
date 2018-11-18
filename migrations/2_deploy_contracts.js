const property = artifacts.require("./Property.sol");
const propertyRegistry = artifacts.require("./PropertyRegistry.sol");
const propertyToken = artifacts.require("./PropertyToken.sol");

module.exports = function(deployer) {
    deployer.deploy(property, "Property", "PROP").then(() => {
         return deployer.deploy(propertyRegistry, property.address).then(() => {
              return deployer.deploy(propertyToken, "propertyToken", "BNB", 2)
         })
      })
};
