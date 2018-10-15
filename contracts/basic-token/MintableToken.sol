pragma solidity ^0.4.24;

import "./BasicToken.sol";

/**
 * @title MintableToken
 * @dev ERC20 minting logic
 */
contract MintableToken is BasicToken {
    modifier onlyMinter() {
        require(msg.sender == owner);
        _;
    }

  /**
   * @dev Function to mint tokens
   * @param to The address that will receive the minted tokens.
   * @param amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address to, uint256 amount) public onlyMinter returns (bool) {
      _mint(to, amount);
      return true;
  }
}
