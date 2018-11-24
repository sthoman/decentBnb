let web3Provider;
web3Provider = new Web3.providers.HttpProvider('http://127.0.0.1:7545/');
window.web3 = new Web3(web3Provider);

accounts = web3.eth.accounts;

ALICE = { from: accounts[0], gas: 250000 };
BOB = { from: accounts[1], gas: 250000 };
ADAM = { from: accounts[2], gas: 250000 };
