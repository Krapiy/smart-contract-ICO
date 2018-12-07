pragma solidity ^0.4.21;

 /* Essentia.one team
 * Oksana Zakharchuk - https://github.com/wt5RM2
 * Nikolay Hryshchenkov
 * site: essentia.one
 */
 
 /* @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    /* @dev Multiplies two numbers, throws on overflow.*/
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /* @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /* @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /* @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

/* @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {

    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

/* @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
    
    using SafeMath for uint256;
    
    mapping(address => uint256) balances;

    uint256 totalSupply_;

    /* @dev total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    /* @dev transfer token for a specified address
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

    /* @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }
}

/* @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/* @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

    mapping (address => mapping (address => uint256)) internal allowed;
    //GitHub
    //ERC: Simpler Token Standard #179
    //ERC: 179 Title: Simpler Token standard Status: Draft Type: Informational Created: 18-11.2016 Resolution: https://github.com/ethereum/wiki/wiki/Standar...
    /* @dev Transfer tokens from one address to another
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

    /* @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
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

    /* @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    /* @dev Increase the amount of tokens that an owner allowed to a spender.
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

    /* @dev Decrease the amount of tokens that an owner allowed to a spender.
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

/* @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {

    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    //GitHub
    //ERC: Token standard #20
    //The final standard can be found here: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md ERC: 20 Title: Token standard Status:...
    /* @dev The Ownable constructor sets the original owner of the contract to the sender
     * account.
     */
    function Ownable() public {
        owner = msg.sender;
    }

    /* @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
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
    function pause() public onlyOwner whenNotPaused {
        paused = true;
        emit Pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyOwner whenPaused {
        paused = false;
        emit Unpause();
    }
}

/* @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */
contract MintableToken is StandardToken, Ownable {

    event Mint(address indexed to, uint256 amount);
    event MintFinished();

    bool public mintingFinished = false;

    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    /* @dev Function to mint tokens
     * @param _to The address that will receive the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address _to, uint256 _amount) public onlyOwner canMint returns (bool) {
        totalSupply_ = totalSupply_.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit  Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }

    /* @dev Function to stop minting new tokens.
     * @return True if the operation was successful.
     */
    function finishMinting() public onlyOwner canMint returns (bool) {
        mintingFinished = true;
        emit MintFinished();
        return true;
    }
}

/**
 * @title Pausable token
 * @dev StandardToken modified with pausable transfers.
 **/
contract PausableToken is MintableToken, Pausable {

  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
    return super.approve(_spender, _value);
  }

  function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {
    return super.decreaseApproval(_spender, _subtractedValue);
  }
}

/* @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is PausableToken {

    event Burn(address indexed burner, uint256 value);

    /* @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint256 _value) public {
        require(_value <= balances[msg.sender]);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        emit Burn(burner, _value);
    }
}

/* @title ESSToken
*  @dev ESS token
*/
contract ESSToken is BurnableToken {

    string public constant NAME = "Essentia Token";

    string public constant SYMBOL = "ESS";

    uint32 public constant DECIMALS = 18;
}

/* @title DevPool
* @dev Smart contract for token distribution inside the team
*/
contract DevPool is Ownable {

    using SafeMath for uint256;

    // duration in sending tokens
    uint private duration;

    // timestamp of starting sending tokens
    uint private start;

    // variable for changing duration
    uint private i = 1;
    
    // is transfer to dev used
    bool private isUsed = false;
    
    // token
    ESSToken public token;

    //total supply off all team tokens
    uint256 private totalTokenSupply = 0;

    //team addresses
    //mapping(uint => address) private teamAddresses;
    address[23]  private teamAddresses;
    
    //team persents
    mapping(address => uint) private teamBalances;

    /* @dev only devs can send tokens to team
        */
    modifier onlyDevs() {
        require(msg.sender == teamAddresses[0] || msg.sender == teamAddresses[1] || msg.sender == teamAddresses[2]);
        _;
    }

    /* @dev first transfer % for team after Crowdsale ends
    */
    function transferToDev() external onlyOwner {
        teamAddresses = [ 
        0x1efCC484849379fA4F313eaadbCc62F9d620e645,
        0xb7586945167e9271E2881E92c13F13a8Cc776406,
        0x4101D2716cB01c3c66923F8B013E886C52Ae7e13,
        0x1fb330Ab08bDBA6E218E55FABc357643cf8252e3,
        0x0A11fa8b2584dcd000089112DAcb368708C43854,
        0x99959a9Ab3FA6D9F5Eb3413f8f00EC6a4F5aEEfD,
        0x5C42d97403db8888c37887E56466FEcF044C4eb4,
        0x85c223b4D0Fd8F1a9525B37965EF4a1125E2AF37,
        0xf91eA637647DC0305A29C40abc40b3788b95A87c,
        0x7Eb795AA14A1816b8C84cB2A7f67DAFECd129842,
        0x38eaC47888bE924bd282E6431730c666ef6BaB0d,
        0x485f50810f261E9165D82050cB09C1198FF018D2,
        0x62600F5B4bCCE26c1E2F4440C210d7031432A5E3,
        0x11663bFddaDd9C85c539De6d0D839A54DB63BeAd,
        0x891485bAFc2Cd2f65C8d03d7b592751C40b78df8,
        0x8AcDF2b16b77eDEE1EE8004fED68D5840Da961fD,
        0xc7f0360272763e84C21267Fe13037993b4e96606,
        0xCa6EaE8674AC2c95f39D87129255761d4b8CB573,
        0x522b35AC608FC556c46EEB957c78bC9Eb00b7148,
        0x187400286579cc12994ec6082456ff9c827341b9,
        0x1C8759C7a5cb664FC5E153Ee928aBe39e760F5E5,
        0x5E52dEA2e5a2C7BacfAbCB496b2ed62954dd216E,
        0x117750cC4609D034Fdd7CB198558E27D7FF4EA74 
    ];

        totalTokenSupply = token.balanceOf(this);
        teamBalances[teamAddresses[0]] = totalTokenSupply.mul(1).div(100);
        teamBalances[teamAddresses[1]] = totalTokenSupply.mul(1).div(100);
        teamBalances[teamAddresses[2]] = totalTokenSupply.mul(1).div(100);
        teamBalances[teamAddresses[3]] = totalTokenSupply.mul(1).div(100);
        teamBalances[teamAddresses[4]] = totalTokenSupply.mul(1).div(100);
        teamBalances[teamAddresses[5]] = totalTokenSupply.mul(1).div(100);
        teamBalances[teamAddresses[6]] = totalTokenSupply.mul(1).div(100);
        teamBalances[teamAddresses[7]] = totalTokenSupply.mul(1).div(100);
        teamBalances[teamAddresses[8]] = totalTokenSupply.mul(1).div(100);
        teamBalances[teamAddresses[9]] = totalTokenSupply.mul(1).div(100);
        teamBalances[teamAddresses[10]] = totalTokenSupply.mul(1).div(100);
        teamBalances[teamAddresses[11]] = totalTokenSupply.mul(1).div(100);
        teamBalances[teamAddresses[12]] = totalTokenSupply.mul(1).div(100);
        teamBalances[teamAddresses[13]] = totalTokenSupply.mul(1).div(100);
        teamBalances[teamAddresses[14]] = totalTokenSupply.mul(1).div(100);
        teamBalances[teamAddresses[15]] = totalTokenSupply.mul(1).div(100);
        teamBalances[teamAddresses[16]] = totalTokenSupply.mul(1).div(100);
        teamBalances[teamAddresses[17]] = totalTokenSupply.mul(1).div(100);
        teamBalances[teamAddresses[18]] = totalTokenSupply.mul(1).div(100);
        teamBalances[teamAddresses[19]] = totalTokenSupply.mul(1).div(100);
        teamBalances[teamAddresses[20]] = totalTokenSupply.mul(1).div(100);
        teamBalances[teamAddresses[21]] = totalTokenSupply.mul(1).div(100);
        teamBalances[teamAddresses[22]] = totalTokenSupply.mul(1).div(100);
        
        for (uint t = 0; t < teamAddresses.length; t++) {
            token.transfer(teamAddresses[t], teamBalances[teamAddresses[t]].mul(2).div(10));
            teamBalances[teamAddresses[t]] = teamBalances[teamAddresses[t]].sub(teamBalances[teamAddresses[t]].mul(2).div(10));
        }
    }

    /* @dev periodical transfers to team during 17 month after transferToDev()
    */
    function sendTokensToDevs() external onlyDevs {
        require(isUsed);
        require(i < 18);
        require(start.add(duration.mul(i)) < now);

        for (uint k = 0; k<teamAddresses.length; k++) {
            token.transfer(teamAddresses[k], teamBalances[teamAddresses[k]].div(17));
        }
        
        i = i + 1;
    }
    
    /*Change one of the team address*/
    function changeDevAddr(address _address, uint _numb) external onlyDevs {
        teamAddresses[_numb] = _address;
    }
    
    /*Checking if dev address is valid*/
    function checkDevAddr(address _address) external view onlyDevs returns(bool) {
        for (uint k = 0; k < teamAddresses.length; k++) {
            if (teamAddresses[k] == _address) {
                return true; 
            }
        }
        return false;
    }

    /* @dev Start transfer tokens to team
    * @param _duration Duration in sending tokens
    * @param _start Start of sending tokens
    * @param _token ESSTokens to send
    */
    function startTransferToDev(uint256 _duration, uint256 _start, ESSToken _token) public onlyOwner {
    
        require(_duration != 0);
        require(_start != 0);
        require(!isUsed);
    
        duration = _duration;
        start = _start;
        token = _token;
        isUsed = true;
    }
}

contract SimpleCrowdsale {

    using SafeMath for uint256;

    // Amount of raised money in wei
    uint256 public weiRaised;

    // Checking for end taking ether
    bool public isFinalized = false;

    // Checking of end crowdsale
    bool public isEnded = false;

    // Timestamp for starting finalization
    uint public timeoutSetting = now;

    //duration
    uint public constant DURATION = 604800;
    
    // how many token units a buyer gets per wei
    uint256 public rate = 15000;

    // Hardcap
    uint private constant CAP = 38700*1 ether;
    
    // start  timestamp where investments are allowed
    uint public constant STARTTIME = 1514764800;
    
    // event for end taking ether
    event Finalized();

    //event for end crowdsale
    event Finalization();

    modifier crowdSaleEnded() {
        require(!isEnded);
        _;
    }

    /* @dev Throws if stop taking ether
    */
    modifier onlyOneFinalize() {
        require(!isFinalized);
        _;
    }
    
     modifier validPurchase() {
        require(now >= STARTTIME);
        require(msg.value != 0);
        _;
    }
    
    // @return true if investors can buy at the moment
    function withinCap() internal view returns (bool) {
        return (weiRaised.add(msg.value) >= CAP);
    }
}

/* @title ESSCrowdsale
* @dev Smart contract for Crowdsale
*/
contract ESSCrowdsale is Ownable, SimpleCrowdsale {

    using SafeMath for uint256;

    // The token being sold
    ESSToken public token = new ESSToken();

    // Smart contract for team
    DevPool public dev = new DevPool();
    
    //Smart contract for white list 
    WhiteList public whiteList = new WhiteList(); 
    
    /* event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param beneficiary who got the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    // addresses where funds are collected
    address private constant WALLET1 = 0xB87643949E5A57a2C5cF160781b2Fd4FF8951a03;
    address private constant WALLET2 = 0xB87643949E5A57a2C5cF160781b2Fd4FF8951a03;
    address private constant WALLET3 = 0xB87643949E5A57a2C5cF160781b2Fd4FF8951a03;
    address private constant WALLET4 = 0xB87643949E5A57a2C5cF160781b2Fd4FF8951a03;

    // Addresses
    address private constant FOUNDERS = 0xB87643949E5A57a2C5cF160781b2Fd4FF8951a03;
    address private constant ADVISORS = 0xB87643949E5A57a2C5cF160781b2Fd4FF8951a03;
    address private constant BOUNTIES = 0xB87643949E5A57a2C5cF160781b2Fd4FF8951a03;
    address private constant REFFERALSYSTEM = 0xf91eA637647DC0305A29C40abc40b3788b95A87c;
    address private constant PROJECTRESERVE = 0x697584753F00c3f2Ed8bf1682FA840323A8166e3;
    address private constant AIRDROP = 0x697584753F00c3f2Ed8bf1682FA840323A8166e3;
    address private constant BLOCKREVARDS = 0x697584753F00c3f2Ed8bf1682FA840323A8166e3;
    
    function ESSCrowdsale() public {
        token.pause();
    }
   
    // fallback function can be used to buy tokens
    function () external payable {
        require(whiteList.checkAddrWL(msg.sender, msg.value));
        
        buyTokens(msg.sender);
    }

    // Override this method to have a way to add business logic to your crowdsale when buying
    function getTokenAmount(uint256 weiAmount) internal view returns(uint256) {
        return weiAmount.mul(rate);
    }

    // send ether to the fund collection wallet
    function forwardFunds() internal {
        WALLET1.transfer(msg.value.div(4));
        WALLET2.transfer(msg.value.div(4));
        WALLET3.transfer(msg.value.div(4));
        WALLET4.transfer(msg.value.div(4));
    }
    
    /* @dev Must be called after crowdsale ends, to do some extra finalization
     * work. Calls the contract's finalization function.
     */
    function finalize() internal onlyOwner {
        require(isFinalized);

        finalization();
        emit Finalized();
    }

    /* @dev Can be overridden to add finalization logic. The overriding function
     * should call super.finalization() to ensure the chain of finalization is
     * executed entirely.
     */
    function finalization() internal onlyOwner {

        // calculate all tokens to all addresses
        uint256 allTokens = token.totalSupply();
        
        token.mint(FOUNDERS, allTokens.mul(12).div(100));
        token.mint(ADVISORS, allTokens.mul(10).div(100));
        token.mint(BOUNTIES, allTokens.mul(12).div(1000));
        token.mint(REFFERALSYSTEM, allTokens.mul(3).div(100));
        token.mint(PROJECTRESERVE, allTokens.mul(21).div(100));
        token.mint(AIRDROP, allTokens.mul(5).div(1000));
        token.mint(BLOCKREVARDS, allTokens.div(10));

        dev.startTransferToDev(2629743, now, token);
        token.mint(dev, allTokens.mul(6).div(100));
        dev.transferToDev();

        emit Finalization();
    }
    
    /* @dev Main function for sending ether and calculate tokens amount
     */
    function mainBuy(address beneficiary) internal {
        uint256 weiAmount = msg.value;
        uint256 tokens = getTokenAmount(weiAmount);
        weiRaised = weiRaised.add(weiAmount);
        forwardFunds();
        token.mint(beneficiary, tokens);
      
        emit TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
    }
    
    /* @dev Crowdsale logic for checking finalization and end
     * @param beneficiary Address beneficiary
     */
    function buyTokens(address beneficiary) internal onlyOneFinalize validPurchase {
        require(beneficiary != address(0));
        bool hardCap = withinCap();
        
        if (hardCap) {
            mainBuy(beneficiary);
            stopICO();
        } else {
            mainBuy(beneficiary);
        }
    }

    /* @dev Stop minting tokens
     */
    function stopMinting() external onlyOwner {
        token.finishMinting();
    }

    /* @dev Burn Your tokens
     */
    function burnTokens(uint256 _value) external onlyOwner {
        token.burn(_value);
    }

    /* @dev Emergency call finalize function
    */
    function stopICO() public onlyOwner onlyOneFinalize crowdSaleEnded {
        timeoutSetting = now + DURATION;
        isFinalized = true;
    }

    /**
     * @dev Send tokens after freeze
     */
    function setTimeout() external onlyOwner crowdSaleEnded {
        require(isFinalized);
        require(timeoutSetting <= now);
        token.unpause();
        finalize();
        isEnded = true;
    }
    
    //mint tokens to the bonus Pool
    function mintToBonusPool(address _address, uint256 _amount) external onlyOwner {
        require(isFinalized);
        
        token.mint(_address, _amount);
    }
}

/*Smart contract for donators*/
contract WhiteList {
    
    mapping (address => uint) private whiteList;
    uint private countOfWLUsers = 0;
    
    //address of the servise that will send addresses of the users to whiteList
    address private devAddr = 0xa9EFF4301C8fd74490dffe131e7Ca7B0e2E58A66;
    
    modifier onlyDev() {
        require(msg.sender == devAddr);
        _;
    }
    
    function addKYC(address _address) external onlyDev {  
        whiteList[_address] = 1;
        countOfWLUsers++;
    }
    
    function addAML(address _address) external onlyDev {  
        whiteList[_address] = 2;
        countOfWLUsers++;
    }
    
    //return count of all whitelisted addresses
    function checkCount() external view returns (uint) {
        return countOfWLUsers;
    }
    
    //retun status of whitelisted addresses
    function checkAddValue(address _address) external view returns (uint256) {
            return (whiteList[_address]); 
    }
    
    //function that used in payble for checking amount of ether that address send
    function checkAddrWL(address _address, uint256 _value) external view returns (bool) {
            return ((whiteList[_address] == 1  && _value < 5*1 ether) || whiteList[_address] == 2 ); 
    }
    
    function addArrayKYC(address[] _address) external onlyDev {
        for (uint i = 0; i < _address.length; i++) {
            whiteList[_address[i]] = 1;
            countOfWLUsers++;
        }
    }
    
     function addArrayAML(address[] _address) external onlyDev {
        for (uint i = 0; i < _address.length; i++) {
            whiteList[_address[i]] = 2;
            countOfWLUsers++;
        }
    }
}