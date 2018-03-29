// Deployer for FabaToken
// Using Factory pattern

var fabaToken = artifacts.require("FabaToken.sol");
var beanFactory = artifacts.require("Factory.sol");

module.exports = function(deployer, network, accounts) {
  deployer.deploy(beanFactory);
};


