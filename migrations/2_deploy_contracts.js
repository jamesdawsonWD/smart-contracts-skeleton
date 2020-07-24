const HedgeManager = artifacts.require("HedgeManager");

module.exports = function(deployer, network) {
  deployer.deploy(HedgeManager)
          .then(() => deployer.deploy(LootBlocks, LootControls.address))

};