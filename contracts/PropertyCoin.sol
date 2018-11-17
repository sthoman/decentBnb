pragma solidity ^0.4.24;

import '../node_modules/zeppelin-solidity/contracts/token/ERC20/StandardToken.sol';

/**
 * @title PropertyCoin An ERC20 used as currency to pay to occupy a property
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 */
contract PropertyCoin is StandardToken {

  string public constant name = "PropertyCoin";
  string public constant symbol = "BNB";
  uint8 public constant decimals = 18;
  uint256 public leftToSell;

  constructor() public {
      // Max 50 tokens
      totalSupply_ = 50*10**uint256(decimals);
      // Set all the tokens to be owned by the contract
      balances[address(this)] = totalSupply_;
      // Keeps track of what is left to sell
      leftToSell = totalSupply_;
  }

  function() payable public {
      // Ensure we have enough to sell
      require(leftToSell > msg.value);
      // Reduce amount left to sell
      leftToSell = leftToSell.sub(msg.value);
      // Transfer the amount of tokens
      require(this.transfer(msg.sender, msg.value));
  }
}
