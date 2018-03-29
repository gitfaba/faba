pragma solidity ^0.4.15;

import 'contracts/FabaToken.sol';

contract Factory {

  address[] public contracts;

  function getContractCount() 
    public
    constant
    returns(uint contractCount)
  {
    return contracts.length;
  }



    function createContract(
        address _fundsWallet,
        uint256 _startTimestamp,
        uint256 _minCapEth,
        uint256 _maxCapEth) 
        public
        returns(address created) 
    {
        FabaToken bt = new FabaToken(
            _fundsWallet,
            _startTimestamp,
            _minCapEth * 1 ether,
            _maxCapEth * 1 ether
        );
        contracts.push(bt);
        return bt;
    }
}

