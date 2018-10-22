const BalanceSheet = artifacts.require("./BalanceSheet.sol");

module.exports = function(deployer, network, accounts) {
  let overwrite = true;

  switch (network) {
    case 'development':
      overwrite = true;
      break;
    default:
        throw new Error ("Unsupported network");
  }

  let registered_user;

  deployer.then (() => {
      return deployer.deploy(BalanceSheet, {overwrite: overwrite});
  }).then(() => {
      return BalanceSheet.deployed();
  }).catch((err) => {
      console.error(err);
      process.exit(1);
  });
};
