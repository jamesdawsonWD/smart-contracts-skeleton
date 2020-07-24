const Migrations = artifacts.require("./truffle/Migrations.sol");

module.exports = function(deployer, network, accounts) {
  console.log(`Using network: ${network}`);
  console.log(`Using accounts`, accounts);
  deployer.deploy(Migrations);
};
