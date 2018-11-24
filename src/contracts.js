
//  Test harness for the contracts. This class initializes each contract,
//  sets up watchers, and provides public methods to interact with each
//  smart contract function needed for the decentralized Airbnb.
//
var BNBContracts = (async function (self, transactSender) {
  var propertyContract, propertyTokenContract, propertyRegistryContract;

  //
  //
  var getContract = function(json, web3 = window.web3) {
    const contract = TruffleContract(json);
    contract.setProvider(web3.currentProvider);
    return contract.deployed();
  }

  var getContractEventCallback = function() {
    return (err, res) => {
      if (err)
        console.log('watch error', err)
      else
        console.log('got an event', res)
    }
  }

  const propertyJson = await fetch('../build/contracts/Property.json').then((res) => res.json());
  propertyContract = await getContract(propertyJson);

  const propertyTokenJson = await fetch('../build/contracts/PropertyToken.json').then((res) => res.json());
  propertyTokenContract = await getContract(propertyTokenJson);

  const propertyRegistryJson = await fetch('../build/contracts/PropertyRegistry.json').then((res) => res.json());
  propertyRegistryContract = await getContract(propertyRegistryJson);

  //  TODO watchers causing a lot of requests
  //
  //propertyContract.allEvents({ fromBlock: 0, toBlock: 'latest' }).watch(getContractEventCallback());
  //propertyTokenContract.allEvents({ fromBlock: 0, toBlock: 'latest' }).watch(getContractEventCallback());
  //propertyRegistryContract.allEvents({ fromBlock: 0, toBlock: 'latest' }).watch(getContractEventCallback());

  //  Creates a property and returns the identifier of the non-
  //  fungible token that represents the newly created property
  //
  async function createProperty(uri) {
    let transaction = await propertyContract.createProperty(transactSender);
    let transactionNft = await propertyContract.tokenOfOwnerByIndex(transactSender.from, 0);
    let transactionSetUri = await propertyContract.setURI(transactionNft.c[0], uri, transactSender);
    return transactionNft.c[0];
  }

  async function registerProperty(tokenId, price) {
    let transaction = await propertyRegistryContract.registerProperty(tokenId, price, transactSender);
    return transaction;
  }

  async function getPropertyDetails() {
    let properties = await propertyRegistryContract.getStayData(transactSender);
    return properties;
  }

  // Also resolves the URI, creating a list of every property
  //
  async function propertyBrowser() {
    let propertiesList = [];
    let properties = await propertyContract.getProperties(transactSender);
    for (var i = 0; i < properties.length; i++) {
      let tokenId = properties[i].c[0];
      let tokenIdStayData = await propertyRegistryContract.getStayData(tokenId, transactSender);
      tokenIdStayData.uri = await propertyContract.getURI.call(tokenId);
      propertiesList.push(tokenIdStayData);
    }
    return propertiesList;
  }

  //
  //
  self.createProperty = createProperty;
  self.registerProperty = registerProperty;
  self.getPropertyDetails = getPropertyDetails;
  self.propertyBrowser = propertyBrowser;
  return self;

}( BNBContracts || {}, ALICE ))
