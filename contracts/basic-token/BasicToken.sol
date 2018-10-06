pragma solidity ^0.4.23;


import "../openzeppelin/math/SafeMath.sol";
import "../openzeppelin/token/ERC20/IERC20.sol";
import "../openzeppelin/ownership/Ownable.sol";
import "./BalanceSheet.sol";

// Version of OpenZeppelin's BasicToken whose balances mapping has been replaced
// with a separate BalanceSheet contract. Most useful in combination with e.g.
// HasNoContracts because then it can relinquish its balance sheet to a new
// version of the token, removing the need to copy over balances.
/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is IERC20, Claimable {
    using SafeMath for uint256;

    BalanceSheet private _balances;

    uint256 private _totalSupply;

    bool public totalSupplySet;

    event BalanceSheetSet(address indexed sheet);

    constructor() public {
      _totalSupply = 0;
      totalSupplySet = false;
    }
    /**
    * @dev claim ownership of the balancesheet contract
    * @param _sheet The address to of the balancesheet to claim.
    */
    function setBalanceSheet(address _sheet) public onlyOwner returns (bool) {
        _balances = BalanceSheet(_sheet);
        _balances.claimOwnership();
        emit BalanceSheetSet(_sheet);
        return true;
    }

    /**
    *@dev set the totalSupply of the contract for delegation purposes
     Can only be set once.
    */
    function setTotalSupply(uint _totalSup) external onlyOwner {
        require(!totalSupplySet, "total supply already set");
        _totalSupply = _totalSup;
        totalSupplySet = true;
    }

    /**
    * @dev total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
    * @dev Transfer token for a specified address
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function transfer(address to, uint256 value) public returns (bool) {
      require(value <= _balances.balanceOf(msg.sender));
      require(to != address(0));

      _balances.subBalance(msg.sender, value);
      _balances.addBalance(to, value);
      emit Transfer(msg.sender, to, value);
      return true;
    }

    /**
     * @dev Transfer tokens from one address to another
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(
      address from,
      address to,
      uint256 value
    )
      public
      returns (bool)
    {
      require(value <= _balances.balanceOf(from));
  //    require(value <= _allowed[from][msg.sender]);
      require(to != address(0));

      _balances.subBalance(from, value);
      _balances.addBalance(to, value);
    //  _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
      emit Transfer(from, to, value);
      return true;
    }

    function transferAllArgs(address _from, address _to, uint256 _value) internal {
        require(_to != address(0),"to address cannot be 0x0");
        require(_from != address(0),"from address cannot be 0x0");
        require(_value <= _balances.balanceOf(_from),"not enough balance to transfer");

        // SafeMath.sub will throw if there is not enough balance.
        _balances.subBalance(_from, _value);
        _balances.addBalance(_to, _value);
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return _balances.balanceOf(_owner);
    }

    /**
     * @dev Internal function that mints an amount of the token and assigns it to
     * an account. This encapsulates the modification of balances such that the
     * proper events are emitted.
     * @param account The account that will receive the created tokens.
     * @param amount The amount that will be created.
     */
    function _mint(address account, uint256 amount) internal {
      require(account != 0);
      _totalSupply = _totalSupply.add(amount);
      _balances.addBalance(account, amount);
      emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account.
     * @param account The account whose tokens will be burnt.
     * @param amount The amount that will be burnt.
     */
    function _burn(address account, uint256 amount) internal {
      require(account != 0);
      require(amount <= _balances.balanceOf(account));

      _totalSupply = _totalSupply.sub(amount);
      _balances.subBalance(account, amount);
      emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account, deducting from the sender's allowance for said account. Uses the
     * internal burn function.
     * @param account The account whose tokens will be burnt.
     * @param amount The amount that will be burnt.
     */
    function _burnFrom(address account, uint256 amount) internal {
      //require(amount <= _allowed[account][msg.sender]);

      // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
      // this function needs to emit an event with the updated approval.
      //_allowed[account][msg.sender] = _allowed[account][msg.sender].sub(amount);
      _burn(account, amount);
    }
}
