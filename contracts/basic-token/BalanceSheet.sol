pragma solidity ^0.4.23;

import "../openzeppelin/ownership/Claimable.sol";
import "../openzeppelin/math/SafeMath.sol";

// A wrapper around the balanceOf mapping.
contract BalanceSheet is Claimable {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    function balanceOf(address _user) public view returns (uint256) {
      return _balances[_user];
    }

    function addBalance(address _addr, uint256 _value) public onlyOwner {
        _balances[_addr] = _balances[_addr].add(_value);
    }

    function subBalance(address _addr, uint256 _value) public onlyOwner {
        _balances[_addr] = _balances[_addr].sub(_value);
    }

    function setBalance(address _addr, uint256 _value) public onlyOwner {
        _balances[_addr] = _value;
    }
}
