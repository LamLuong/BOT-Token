pragma solidity ^0.4.24;

import "./basic-token/PausableToken.sol";
import "./basic-token/MintableToken.sol";
import "./basic-token/BurnableToken.sol";
import "./openzeppelin/math/SafeMath.sol";
// This is the top-level ERC20 contract, but most of the interesting functionality is
// inherited - see the documentation on the corresponding contracts.
contract BOTToken is BurnableToken, MintableToken, PausableToken {
  using SafeMath for *;
  uint256 public totalCharges;
  uint256 public currentCharges;
  address public investor;

  constructor(uint256 _totalChage, address _investor) public {
    currentCharges = 0;
    totalCharges = _totalChage;
    investor = _investor;
  }

  function payServiceFee(uint256 _fee) public {
    require(currentCharges < totalCharges);
    bool result = super.transfer(investor, _fee);
    if (result) {
      currentCharges = currentCharges.add(_fee);
    }
  }
}
