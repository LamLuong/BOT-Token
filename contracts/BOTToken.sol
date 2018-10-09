pragma solidity ^0.4.24;

import "./basic-token/PausableToken.sol";
import "./basic-token/MintableToken.sol";
import "./basic-token/BurnableToken.sol";
import "./openzeppelin/math/SafeMath.sol";

// This is the top-level ERC20 contract, but most of the interesting functionality is
// inherited - see the documentation on the corresponding contracts.
contract BOTToken is BurnableToken, MintableToken, PausableToken {
  using SafeMath for uint256;

  string public constant name = "BOTToken";
  string public constant symbol = "BOT";

  uint8 public constant decimals = 9;
  uint256 public constant TOTAL_TOKENS = 100 * (10**9) * (10 ** uint256(decimals)); // 100 billion

  address public wallet;
  uint256 public defaultFee;
  uint256 public rate;
  uint256 public capCharges;
  uint256 public currentCharges;

  event SetRate(uint256 _rate);
  event ChangeDefaultFee(uint256 _defaultFee);

  constructor(address _wallet, uint256 _capChage, uint256 _rate, uint256 _defaultFee) public {
    wallet = _wallet;
    rate = _rate;
    defaultFee = _defaultFee;
    capCharges = _capChage;
    currentCharges = 0;

    emit SetRate(_rate);
  }

  function setRate(uint256 _rate) public onlyOwner returns(bool) {
    rate = _rate;
    emit SetRate(_rate);

    return true;
  }

  function changeWallet(address _wallet) public onlyOwner returns(bool) {
    wallet = _wallet;

    return true;
  }

  function changeDefaultFee(uint256 _defaultFee) public onlyOwner returns(bool) {
    defaultFee = _defaultFee;
    emit ChangeDefaultFee(_defaultFee);

    return true;
  }

  function payServiceFeeUseEther() external payable {
    uint256 _weiAmount = msg.value;
    uint256 _fee = _getTokenAmount(_weiAmount);

    require(_fee >= defaultFee);
    require(currentCharges <= capCharges);
    bool result = super.transfer(this, _fee);
    if (result) {
      currentCharges = currentCharges.add(_fee);
    }

    _forwardFunds();
  }

  function payServiceFeeUseToken(uint256 _fee) external {
    require(_fee >= defaultFee);
    require(currentCharges <= capCharges);

    bool result = super.transfer(this, _fee);
    if (result) {
      currentCharges = currentCharges.add(_fee);
    }
  }

  /**
   * @dev Override to extend the way in which ether is converted to tokens.
   * @param weiAmount Value in wei to be converted into tokens
   * @return Number of tokens that can be purchased with the specified _weiAmount
   */
  function _getTokenAmount(uint256 weiAmount)
    internal view returns (uint256)
  {
    return weiAmount.mul(rate);
  }

  /**
   * @dev Determines how ETH is stored/forwarded on purchases.
   */
  function _forwardFunds() internal {
    wallet.transfer(msg.value);
  }
}
