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
    mapping (address => mapping (address => uint256)) private _allowed;
    uint256 private _totalSupply;

    event BalanceSheetSet(address indexed sheet);

    constructor() public {
      _totalSupply = 0;
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
      require(value <= _allowed[from][msg.sender]);
      require(to != address(0));

      _balances.subBalance(from, value);
      _balances.addBalance(to, value);
      _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
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
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
      _allowed[msg.sender][_spender] = _value;
      emit Approval(msg.sender, _spender, _value);
      return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(
      address _owner,
      address _spender
     )
      public
      view
      returns (uint256)
    {
      return _allowed[_owner][_spender];
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param _spender The address which will spend the funds.
     * @param _addedValue The amount of tokens to increase the allowance by.
     */
    function increaseApproval(
      address _spender,
      uint256 _addedValue
    )
      public
      returns (bool)
    {
      _allowed[msg.sender][_spender] = (
        _allowed[msg.sender][_spender].add(_addedValue));
      emit Approval(msg.sender, _spender, _allowed[msg.sender][_spender]);
      return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param _spender The address which will spend the funds.
     * @param _subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseApproval(
      address _spender,
      uint256 _subtractedValue
    )
      public
      returns (bool)
    {
      uint256 oldValue = _allowed[msg.sender][_spender];
      if (_subtractedValue >= oldValue) {
        _allowed[msg.sender][_spender] = 0;
      } else {
        _allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
      }
      emit Approval(msg.sender, _spender, _allowed[msg.sender][_spender]);
      return true;
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
}
