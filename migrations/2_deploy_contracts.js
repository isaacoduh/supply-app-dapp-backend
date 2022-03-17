const Orders = artifacts.require("Orders");

module.exports = function(deployer) {
  deployer.deploy(Orders);
};