# decentBnb
Decentralized Airbnb project for LHL October 2018 cohort. 

### Setup

Currently built with Google Cloud Datastore, BigQuery, Tensorflow, Keras, for application with the Kraken Exchange API.
    
### Structure

|folder|description|
|---|---|
| `/contracts`| Smart contract implementations, using the ERC721 Non-fungible token standard to represent a property
| `/migrations`| Scripts to deploy the smart contracts to the Ethereum blockchain 
| `/src`| JavaScript wrappers using Truffle contract and web3, to interact with the blockchain over JSONRPC
| `/test`| Mocha tests for the smart contracts
