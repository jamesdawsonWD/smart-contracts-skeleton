pragma solidity 0.6.6;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}



interface IKyberNetworkProxy {

    event ExecuteTrade(
        address indexed trader,
        IERC20 src,
        IERC20 dest,
        address destAddress,
        uint256 actualSrcAmount,
        uint256 actualDestAmount,
        address platformWallet,
        uint256 platformFeeBps
    );

    /// @notice backward compatible
    function tradeWithHint(
        ERC20 src,
        uint256 srcAmount,
        ERC20 dest,
        address payable destAddress,
        uint256 maxDestAmount,
        uint256 minConversionRate,
        address payable walletId,
        bytes calldata hint
    ) external payable returns (uint256);

    function tradeWithHintAndFee(
        IERC20 src,
        uint256 srcAmount,
        IERC20 dest,
        address payable destAddress,
        uint256 maxDestAmount,
        uint256 minConversionRate,
        address payable platformWallet,
        uint256 platformFeeBps,
        bytes calldata hint
    ) external payable returns (uint256 destAmount);

    function trade(
        IERC20 src,
        uint256 srcAmount,
        IERC20 dest,
        address payable destAddress,
        uint256 maxDestAmount,
        uint256 minConversionRate,
        address payable platformWallet
    ) external payable returns (uint256);

    /// @notice backward compatible
    /// @notice Rate units (10 ** 18) => destQty (twei) / srcQty (twei) * 10 ** 18
    function getExpectedRate(
        ERC20 src,
        ERC20 dest,
        uint256 srcQty
    ) external view returns (uint256 expectedRate, uint256 worstRate);

    function getExpectedRateAfterFee(
        IERC20 src,
        IERC20 dest,
        uint256 srcQty,
        uint256 platformFeeBps,
        bytes calldata hint
    ) external view returns (uint256 expectedRate);
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract HedgeManagement is Ownable {
	IKyberNetworkProxy kyberProxy;
	
	uint public hedgeFund;
	uint public totalTraders = 0;
	uint public totalInvestors = 0;

	enum Status {open, paused, closed}
	mapping(uint256 => Status) public traderStatus;
	mapping(address => uint) public addressToTradeAccount;
	mapping(address => uint) public addressToInvestorAccount;

	mapping(uint => address) public traders;
	mapping(uint => address) public investors;

	modifier traderOnly(uint256 _id) {
		require(traders[_id] == msg.sender, "HedgeManager#traderOnly: ONLY_TRADER_ALLOWED");
		_;
  	}

	modifier traderOpen(uint256 _id) {
		require(traderStatus[_id] == Status.open, "HedgeManager#traderOpen: ONLY_OPEN_TRADE_ACCOUNTS_ALLOWED");
		_;
	}

	modifier investorOnly(uint256 _id) {
		require(investors[_id] == msg.sender, "HedgeManager#investorOnly: ONLY_INVESTOR_ALLOWED");
		_;
  	}

	function addInvestor(address _address) public onlyOwner {
		totalInvestors++;
		investors[totalInvestors] = _address;
		addressToInvestorAccount[_address] = totalInvestors;
	}

	function addTrader(address payable _address) public onlyOwner {
		totalTraders++;
		traders[totalTraders] = _address;
		addressToTradeAccount[_address] = totalTraders;
	}

	function pauseTrader(uint256 _id) public onlyOwner {
		traderStatus[_id] = Status.paused;
	}

	function openTrader(uint256 _id) public onlyOwner {
		traderStatus[_id] = Status.open;
	}
	function closeTrader(uint256 _id) public onlyOwner {
		traderStatus[_id] = Status.closed;
	}
}

contract Trader is HedgeManagement {
	mapping(uint => uint) public equity;
	mapping(uint => mapping(address => uint)) public investments;

	function trade(uint256 _id) public traderOnly(_id) {

	}

}

contract Investor is Trader {
	mapping(address => uint) private balances;
	mapping(address => uint) private totalInvested;

	function getBalance() public view return(uint){
		return balances[msg.sender];
	}

	function getTotalInvested() public view return(uint){
		return totalInvested[msg.sender];
	}

  	/**
    * @dev invest in a trader by paying directly into their account
    * @param _id uint256 ID of the traders account
    */
	function invest(uint _id) public payable {
		//convert to dai
		require(msg.value > 0, "Investor#invest: AMOUNT_LESS_THAN_ZERO");
		require(traders[_id] != 0, "Investor#invest: TRADER_DOES_NOT_EXIST");

		hedgeFund += msg.value;
		equity[_id] += msg.value;
		totalInvested[msg.sender] += msg.value;
		investments[_id][msg.sender] += msg.value;
	}

	/**
    * @dev invest in a trader by paying with the senders balance
    * @param _id uint256 ID of the traders account
	* @param _amount the amount do be invested
    */
	function invest(uint _id, uint _amount) public {
		require(_amount > 0, "Investor#invest: AMOUNT_LESS_THAN_ZERO");
		require(traders[_id] != 0, "Investor#invest: TRADER_DOES_NOT_EXIST");

		uint _balance = balances[msg.sender];
		require(_balance > 0, "Investor#invest: BALANCE_EMPTY");
		require(_balance >= _amount, "Investor#invest: AMOUNT_GREATER_THAN_BALANCE");

		balances[msg.sender] -= _amount;
		equity[_id] += _amount;
		totalInvested[msg.sender] += _amount;
		investments[_id][msg.sender] += _amount;
	}

	/**
    * @dev close an full investment with a trader
    * @param _id uint256 ID of the traders account
    */
	function close(uint _id) public {
		require(traders[_id] != 0, "Investor#invest: TRADER_DOES_NOT_EXIST");

		uint _investment = investments[_id][msg.sender];
		require(_investment > 0, "Investor#close: BALANCE_EMPTY");

		equity[_id] -= _investment;
		balances[msg.sender] += _investment;
		totalInvested[msg.sender] -= _investment;
		investments[_id][msg.sender] = 0;
	}

	/**
    * @dev close a certain amount from an investment
    * @param _id uint256 ID of the traders account
	* @param _amount the amount do be closed
    */
	function close(uint _id, uint _amount) public {
		require(traders[_id] != 0, "Investor#invest: TRADER_DOES_NOT_EXIST");

		uint _investment = investments[_id][msg.sender];
		require(_investment > 0, "Investor#close: BALANCE_EMPTY");
		require(_investment >= _amount, "Investor#close: AMOUNT_GREATER_THAN_INVESTMENT");

		equity[_id] -= _investment;
		balances[msg.sender] += _amount;
		totalInvested[msg.sender] -= _amount;
		investments[_id][msg.sender] -= _amount;
	}

	/**
    * @dev withdraw all from balance
    */
	function withdraw() public {
		uint _balance = balances[msg.sender];
		require(_balance > 0, "Investor#withdraw: BALANCE_EMPTY");
		
		payable(msg.sender).transfer(_balance);
		balances[msg.sender] -= _amount;
	}
	/**
    * @dev withdraw amount from balance
    * @param _amount the amount do be withdrawn
    */
	function withdraw(uint256 _amount) public {
		require(_amount > 0, "Investor#withdraw: AMOUNT_LESS_THAN_ZERO");
		
		uint _balance = balances[msg.sender];
		require(_balance > 0, "Investor#withdraw: BALANCE_EMPTY");
		require(_balance >= _amount, "Investor#withdraw: AMOUNT_GREATER_THAN_BALANCE");
	
		payable(msg.sender).transfer(_amount);
		balances[msg.sender] -= _amount;
	}

	/**
    * @dev withdraw amount from balance to specific address
    * @param _amount the amount do be withdrawn
	* @param _address the address to transfer the amount to
    */
	function withdraw(uint256 _amount, address _address) public {
		require(_amount > 0, "Investor#withdraw: AMOUNT_LESS_THAN_ZERO");
		
		uint _balance = balances[msg.sender];
		require(_balance > 0, "Investor#withdraw: BALANCE_EMPTY");
		require(_balance >= _amount, "Investor#withdraw: AMOUNT_GREATER_THAN_BALANCE");
	
		payable(_address).transfer(_amount);
		balances[msg.sender] -= _amount;
	}

	function deposit() public payable {
		require(msg.value > 0, "Investor#deposit: AMOUNT_LESS_THAN_ZERO");
		balances[msg.sender] += msg.value;
	}

	function recieve() external payable {deposit();}
}