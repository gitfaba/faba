pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol';
import 'zeppelin-solidity/contracts/token/ERC20/StandardToken.sol';


/**
 * @title Bean Token 1
 * @dev Simple Standard Token
 * `StandardToken` functions.
 */
contract FabaToken is StandardToken {

  using SafeMath for uint256;

  mapping(address => uint256) balances;

  string public constant name = "FabaToken"; // solium-disable-line uppercase
  string public constant symbol = "FABA"; // solium-disable-line uppercase
  uint8 public constant decimals = 18; // solium-disable-line uppercase

  uint256 public constant INITIAL_SUPPLY = 16000000 * (10 ** uint256(decimals));

  /**
   * @dev Constructor that gives msg.sender all of existing tokens.
   */
  uint256 public totalSupply = INITIAL_SUPPLY;
  uint256 public totalRaised; // total ether raised (in wei)

  uint256 public startTimestamp; // timestamp after which ICO will start
  uint256 public durationSeconds = 2 * 7 * 24 * 60 * 60; // 2 weeks
  uint256 public durationSeconds4 = 4 * 7 * 24 * 60 * 60; // 4 weeks

  uint256 public minCap; // the ICO ether goal (in wei)
  uint256 public maxCap; // the ICO ether max cap (in wei)


  // Added voting from http://solidity.readthedocs.io/en/develop/solidity-by-example.html

  // This declares a new complex type which will
  // be used for variables later.
  // It will represent a single voter.
  struct Voter {
    uint weight; // weight is accumulated by delegation
    bool voted;  // if true, that person already voted
    address delegate; // person delegated to
    uint vote;   // index of the voted proposal
  }

  // This is a type for a single proposal.
  struct Proposal {
    bytes32 name;   // short name (up to 32 bytes)
    uint voteCount; // number of accumulated votes
  }

  address public chairperson;

  // This declares a state variable that
  // stores a `Voter` struct for each possible address.
  mapping(address => Voter) public voters;

  // A dynamically-sized array of `Proposal` structs.
  Proposal[] public proposals;


  // Added dividens distribution in ETH according to 
  // https://medium.com/@dejanradic.me/pay-dividend-in-ether-using-token-contract-104499de116a

  uint256 public totalDividends;
  struct Account {
    uint256 balance;
    uint256 lastDividends;
  } 

  mapping (address => Account) accounts;


  /**
   * Address which will receive raised funds 
   * and owns the total supply of tokens
   */
    address public fundsWallet;

    function FabaToken(
        address _fundsWallet,
        uint256 _startTimestamp,
        uint256 _minCap,
        uint256 _maxCap) {
        fundsWallet = _fundsWallet;
        startTimestamp = _startTimestamp;
        minCap = _minCap;
        maxCap = _maxCap;

        // initially assign all tokens to the fundsWallet
        balances[fundsWallet] = totalSupply;
        Transfer(0x0, fundsWallet, totalSupply);
    }


    function() isIcoOpen payable {
        totalRaised = totalRaised.add(msg.value);

        uint256 tokenAmount = calculateTokenAmount(msg.value);
        balances[fundsWallet] = balances[fundsWallet].sub(tokenAmount);
        balances[msg.sender] = balances[msg.sender].add(tokenAmount);
        Transfer(fundsWallet, msg.sender, tokenAmount);

        // immediately transfer ether to fundsWallet
        fundsWallet.transfer(msg.value);
    }

    function calculateTokenAmount(uint256 weiAmount) constant returns(uint256) {
        // standard rate: 1 USD = 1 FABA
        uint256 tokenAmount = weiAmount.mul(50);
        if (now <= startTimestamp + 7 days) {
            // +50% bonus during first week               // TODO: check the numbers!
            return tokenAmount.mul(150).div(100);
        } else {
            return tokenAmount;
        }
    }

    function transfer(address _to, uint _value) isIcoFinished returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint _value) isIcoFinished returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    modifier isIcoOpen() {
        require(now >= startTimestamp);
        require(now <= (startTimestamp + durationSeconds) || totalRaised < minCap);
        require(totalRaised <= maxCap);
        _;
    }

    modifier isIcoFinished() {
        require(now >= startTimestamp);
        require(totalRaised >= maxCap || (now >= (startTimestamp + durationSeconds) && totalRaised >= minCap));
        _;
    }


    // Added voting


    /// Create a new ballot to choose one of `proposalNames`.
    function Ballot(bytes32[] proposalNames) public {
        chairperson = msg.sender;
        voters[chairperson].weight = 1;

        // For each of the provided proposal names,
        // create a new proposal object and add it
        // to the end of the array.
        for (uint i = 0; i < proposalNames.length; i++) {
            // `Proposal({...})` creates a temporary
            // Proposal object and `proposals.push(...)`
            // appends it to the end of `proposals`.
            proposals.push(Proposal({
                name: proposalNames[i],
                voteCount: 0
            }));
        }
    }

    // Give `voter` the right to vote on this ballot.
    // May only be called by `chairperson`.
    function giveRightToVote(address voter) public {
        // If the argument of `require` evaluates to `false`,
        // it terminates and reverts all changes to
        // the state and to Ether balances. It is often
        // a good idea to use this if functions are
        // called incorrectly. But watch out, this
        // will currently also consume all provided gas
        // (this is planned to change in the future).
        require(
            (msg.sender == chairperson) &&
            !voters[voter].voted &&
            (voters[voter].weight == 0)
        );
        voters[voter].weight = 1;
    }



    /// Delegate your vote to the voter `to`.
    function delegate(address to) public {
        // assigns reference
        Voter storage sender = voters[msg.sender];
        require(!sender.voted);

        // Self-delegation is not allowed.
        require(to != msg.sender);

        // Forward the delegation as long as
        // `to` also delegated.
        // In general, such loops are very dangerous,
        // because if they run too long, they might
        // need more gas than is available in a block.
        // In this case, the delegation will not be executed,
        // but in other situations, such loops might
        // cause a contract to get "stuck" completely.
        while (voters[to].delegate != address(0)) {
            to = voters[to].delegate;

            // We found a loop in the delegation, not allowed.
            require(to != msg.sender);
        }

        // Since `sender` is a reference, this
        // modifies `voters[msg.sender].voted`
        sender.voted = true;
        sender.delegate = to;
        Voter storage delegate_ = voters[to];
        if (delegate_.voted) {
            // If the delegate already voted,
            // directly add to the number of votes
            proposals[delegate_.vote].voteCount += sender.weight;
        } else {
            // If the delegate did not vote yet,
            // add to her weight.
            delegate_.weight += sender.weight;
        }
    }

    /// Give your vote (including votes delegated to you)
    /// to proposal `proposals[proposal].name`.
    function vote(uint proposal) public {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted);
        sender.voted = true;
        sender.vote = proposal;

        // If `proposal` is out of the range of the array,
        // this will throw automatically and revert all
        // changes.
        proposals[proposal].voteCount += sender.weight;
    }

    /// @dev Computes the winning proposal taking all
    /// previous votes into account.
    function winningProposal() public view
            returns (uint winningProposal_)
    {
        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal_ = p;
            }
        }
    }

    // Calls winningProposal() function to get the index
    // of the winner contained in the proposals array and then
    // returns the name of the winner
    function winnerName() public view
            returns (bytes32 winnerName_)
    {
        winnerName_ = proposals[winningProposal()].name;
    }


    // Added dividends

    function () public payable {
       totalDividends = totalDividends.add(msg.value);
    }

    function dividendBalanceOf(address account) public constant returns (uint256) {
        var newDividends =     totalDividends.sub(accounts[account].lastDividends);
        var product = accounts[account].balance.mul(newDividends);
        return product.div(totalSupply);
    }

    function claimDividend() public {
        var owing = dividendBalanceOf(msg.sender);
        if (owing > 0) {
          msg.sender.transfer(owing);
          accounts[msg.sender].lastDividends = totalDividends;
        }
    }


    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_to != address(0));
        require(_value <= accounts[_from].balance);
        require(accounts[_to].balance + _value < accounts[_to].balance);
 
        var fromOwing = dividendBalanceOf(_from);
        var toOwing = dividendBalanceOf(_to);
        require(fromOwing <= 0 && toOwing <= 0);
 
        accounts[_from].balance = accounts[_from].balance.sub(_value);
        accounts[_to].balance = accounts[_to].balance.add(_value);
 
        accounts[_to].lastDividends = accounts[_from].lastDividends;
 
        Transfer(_from, _to, _value);
    }

// Smart contract end
}

// Temporary values to use in testing:

// var now = Math.floor(new Date().getTime() / 1000);
// var ICOstart = Math.floor(new Date('2018-04-04').getTime() /1000)
// var Phase1 = Math.floor(new Date('2018-04-01').getTime() /1000)
// var Phase2 = Math.floor(new Date('2018-04-08').getTime() /1000)
// var Phase3 = Math.floor(new Date('2018-04-15').getTime() /1000)


// EOF

