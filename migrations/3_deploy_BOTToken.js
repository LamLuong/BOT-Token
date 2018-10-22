const BalanceSheet = artifacts.require("./BalanceSheet.sol");
const BOTToken = artifacts.require("./BOTToken.sol");

module.exports = function(deployer, network, accounts) {
  let overwrite = true;
  let _defauleFee = 100;
  let _systemWallet = accounts[0];
  let _capCharges = 10000000000000000000000000;
  let _rate = 1000000000;
  let id = 2;

  switch (network) {
    case 'development':
      overwrite = true;
      break;
    default:
        throw new Error ("Unsupported network");
  }

  let balance_sheet;
  let token;

  deployer.then (() => {
    return BalanceSheet.deployed();
  }).then(contract => {
    balance_sheet = contract;
    return deployer.deploy(BOTToken, _systemWallet, _capCharges, _rate, _defauleFee, {overwrite: overwrite});
  })
  .then(contract => {
    token = contract;
    balance_sheet.transferOwnership(token.address);
  })
  .then(() => {
    token.setBalanceSheet(balance_sheet.address);
  }).catch((err) => {
      console.error(err);
      process.exit(1);
  });

  // deployer.then (() => {
  //     return deployer.deploy(BOTToken, _systemWallet, _capCharges, _rate, _defauleFee, {overwrite: overwrite});
  // }).then(() => {
  //     return BOTToken.deployed();
  // }).catch((err) => {
  //     console.error(err);
  //     process.exit(1);
  // });
};
