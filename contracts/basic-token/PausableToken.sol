pragma solidity ^0.4.24;

import "../openzeppelin/lifecycle/Pausable.sol";
import "./BasicToken.sol";
/**
 * @title Pausable token
 * @dev ERC20 modified with pausable transfers.
 **/
contract PausableToken is BasicToken, Pausable {

  function transfer(
    address to,
    uint256 value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transfer(to, value);
  }

  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transferFrom(from, to, value);
  }

  function approve(
    address spender,
    uint256 value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.approve(spender, value);
  }

  function increaseApproval(
    address spender,
    uint addedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.increaseApproval(spender, addedValue);
  }

  function decreaseApproval(
    address spender,
    uint subtractedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.decreaseApproval(spender, subtractedValue);
  }
}
