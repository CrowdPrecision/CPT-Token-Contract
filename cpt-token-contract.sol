pragma solidity ^0.4.21;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    owner = newOwner;
    emit OwnershipTransferred(owner, newOwner);
  }

}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b > 0);
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}

/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is BasicToken {

    event Burn(address indexed burner, uint256 value);

    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint256 _value) public {
        require(_value <= balances[msg.sender]);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(burner, _value);
    }
}


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}


/*
 * CrowdPrecisionToken is a standard ERC20 token with some additional functionalities:
 * - Transfers are only enabled after contract owner enables it (after the ITS)
 * - Contract sets 75% of the total supply as allowance for ITS contract
 */
contract CrowdPrecisionToken is StandardToken, BurnableToken, Ownable 
{
    string public constant symbol = "CPT";
    string public constant name = "CrowdPrecision Token";
    uint8 public constant decimals = 18;
    uint256 public constant INITIAL_SUPPLY = 45000000000 * ( 10 ** uint256( decimals ) );
    uint256 public constant TOKEN_SALE_ALLOWANCE = 3150000000 * ( 10 ** uint256( decimals ) );
    uint256 public constant ADMIN_ALLOWANCE = INITIAL_SUPPLY - TOKEN_SALE_ALLOWANCE;
    
    address public adminAddr;
    address public tokenSaleAddr;
    bool public transferEnabled = false;
    
    modifier onlyWhenTransferAllowed( ) 
    {
        require( transferEnabled 
                || msg.sender == adminAddr 
                || msg.sender == tokenSaleAddr );
        _;
    }

    modifier onlyTokenSaleAddrNotSet( ) 
    {
        require( tokenSaleAddr == address( 0x0 ) );
        _;
    }

    modifier validDestination( address to ) 
    {
        require( to != address( 0x0 ) );
        require( to != address( this ) );
        require( to != owner );
        require( to != address( adminAddr ) );
        require( to != address( tokenSaleAddr ) );
        _;
    }
    
    function CrowdPrecisionToken( address admin ) public 
    {
        totalSupply = INITIAL_SUPPLY;
        balances[ msg.sender ] = totalSupply;
        emit Transfer( address( 0x0 ), msg.sender, totalSupply );

        adminAddr = admin;
        approve( adminAddr, ADMIN_ALLOWANCE );
    }

    function setTokenSale( address saleAddr, uint256 amountForSale ) external onlyOwner onlyTokenSaleAddrNotSet 
    {
        require( !transferEnabled );

        uint256 amount = ( amountForSale == 0 ) ? TOKEN_SALE_ALLOWANCE : amountForSale;
        require( amount <= TOKEN_SALE_ALLOWANCE );

        approve( saleAddr, amount );
        tokenSaleAddr = saleAddr;
    }
    
    function enableTransfer( ) external onlyOwner 
    {
        transferEnabled = true;
        // Remove the allowance to spend tokens
        approve( tokenSaleAddr, 0 );
    }

    function transfer( address to, uint256 value ) public onlyWhenTransferAllowed validDestination( to ) returns ( bool ) 
    {
        return super.transfer( to, value );
    }
    
    function transferFrom( address from, address to, uint256 value ) public onlyWhenTransferAllowed validDestination( to ) returns ( bool ) 
    {
        return super.transferFrom( from, to, value );
    }
    
    function burn( uint256 value ) public 
    {
        require( transferEnabled 
                || msg.sender == owner );
        super.burn( value );
    }
}

contract CrowdPrecisionTokenSale is Pausable 
{
    address cptAddress = this;
    
    using SafeMath for uint256;

    uint256 public startTime;
    
    uint256 public endTime;

    // Address where funds are collected
    address public beneficiary;

    CrowdPrecisionToken public token;

    // Tokens per ether
    uint256 public rate;

    uint256 public weiRaised;
    
    mapping( address => bool ) public whitelist;

    mapping( address => uint256 ) public contributions;

    // Change to equal $31.5M at time of token sale
    uint256 public constant FUNDING_ETH_HARD_CAP = 60844 * 1 ether;

    uint256 public constant MINIMUM_CONTRIBUTION = 10**17; //0.1 ether
    
    uint256 public constant MAXIMUM_CONTRIBUTION = 5 ether;

    Stages public stage;

    enum Stages { 
        Setup,
        SaleStarted,
        SaleEnded,
        Refunding
    }

    event SaleOpens( uint256 startTime, uint256 endTime );
    
    event SaleCloses( uint256 endTime, uint256 totalWeiRaised );
    
    event RefundingStarted( uint256 startTime );
    
    event TokenPurchase( address indexed purchaser, uint256 value, uint256 amount );

    modifier atStage( Stages expectedStage ) 
    {
        require( stage == expectedStage );
        _;
    }

    modifier validPurchase( ) 
    {
        require( now >= startTime 
                && now <= endTime
                && stage == Stages.SaleStarted );
        
        uint256 contributionInWei = msg.value;
        address participant = msg.sender;
        //What if participant has previously contributed? Should an additional contribution of less then 0.1 ether be allowed?
        require(participant != address(0) && contributionInWei >= MINIMUM_CONTRIBUTION);
        require(weiRaised.add(contributionInWei) <= FUNDING_ETH_HARD_CAP);
        require(contributions[participant].add(contributionInWei) <= MAXIMUM_CONTRIBUTION);
        _;
    }

    function CrowdPrecisionTokenSale(
        uint256 cptToEtherRate, 
        address beneficiaryAddr,
        address tokenAddress
    ) public 
    {
        require( cptToEtherRate > 0 );
        require( beneficiaryAddr != address( 0 ) );
        require( tokenAddress != address( 0 ) );

        token = CrowdPrecisionToken( tokenAddress );
        rate = cptToEtherRate;
        beneficiary = beneficiaryAddr;
        stage = Stages.Setup;
    }

    /**
     * Fallback function can be used to buy tokens
     */
    function ( ) public payable 
    {
        buy( );
    }

    /**
     * Withdraw available ethers into beneficiary account, serves as a safety, should never be needed
     * TODO: may be remove this method?
     */
    function ownerSafeWithdrawal( ) external onlyOwner 
    {
        beneficiary.transfer( cptAddress.balance );
    }

    function updateRate( uint256 cptToEtherRate ) public onlyOwner atStage( Stages.Setup ) 
    {
        rate = cptToEtherRate;
    }
    
    function addToWhitelist( address[] users ) public onlyOwner atStage( Stages.Setup )
    {
        for( uint32 i = 0; i < users.length; i++ ) 
        {
            whitelist[ users[ i ] ] = true;
        }
    }

    function startSale( uint256 durationInSeconds ) public onlyOwner atStage( Stages.Setup ) 
    {
        stage = Stages.SaleStarted;
        startTime = now;
        endTime = durationInSeconds;
        emit SaleOpens( startTime, endTime );
    }

    function endSale( ) public onlyOwner atStage( Stages.SaleStarted ) 
    {
        endSaleImpl( );
    }
    
    function endSaleImpl( ) internal 
    {
        endTime = now;
        stage = Stages.SaleEnded;
        emit SaleCloses( endTime, weiRaised );
    }
    
    function startRefunding( ) public onlyOwner atStage( Stages.SaleEnded ) 
    {
        startRefundingImpl( );
    }
    
    function startRefundingImpl( ) internal 
    { //TODO: startRefunding automatically if soft cap was not reached.
        startTime = now;
        stage = Stages.Refunding;
        emit RefundingStarted( startTime );
    }
    
    function buy( ) public payable whenNotPaused atStage( Stages.SaleStarted ) validPurchase returns ( bool ) 
    {
        if( whitelist[msg.sender] ) 
        {
            address participant = msg.sender;
            uint256 contributionInWei = msg.value;
            uint256 tokens = contributionInWei.mul(rate);
        
            if ( !token.transferFrom( token.owner( ), participant, tokens ) ) 
            {
                revert( );
            }

            weiRaised = weiRaised.add( contributionInWei );
            contributions[ participant ] = contributions[ participant ].add( contributionInWei );
            
            if ( weiRaised >= FUNDING_ETH_HARD_CAP ) 
            {
                endSaleImpl( );
            }
        
            beneficiary.transfer( contributionInWei );
            emit TokenPurchase( msg.sender, contributionInWei, tokens );
        
            return true;
        }
        revert( );
    }

    function hasEnded( ) public view returns ( bool ) 
    {
        return now > endTime || stage == Stages.SaleEnded;
    }

    //TODO: check if this is safe, if reentrancy is not possible, if contribution is reverted if transfer failes.
    function withdrawRefund( ) public whenNotPaused atStage( Stages.SaleEnded ) returns( bool ) 
    {
        address participant = msg.sender;
        uint refund = contributions[ participant ];
        contributions[ participant ] = 0;
        participant.transfer( refund );
        return true;
    }
}
