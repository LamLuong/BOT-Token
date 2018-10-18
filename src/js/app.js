App = {
  web3Provider: null,
  contracts: {},

  init: function() {
    return App.initWeb3();
  },

  initWeb3: function() {
    if (typeof init_web3 !== 'undefined') {
      App.web3Provider = init_web3.currentProvider;
    } else {
      App.web3Provider = new Web3.providers.HttpProvider('http://127.0.0.1:8545');
    }
    init_web3 = new Web3(App.web3Provider);

    $(".dealer-acc").text(init_web3.eth.accounts[0]);

    return App.initContract();
  },

  initContract: function() {
    $.getJSON('BOTToken.json', function(data) {
      var BOTToken = data;
      App.contracts.BOTToken = TruffleContract(BOTToken);
      App.contracts.BOTToken.setProvider(App.web3Provider);
      return App.initAccountContractData();
    });
    return App.bindEvents();
  },

  initAccountContractData: function() {
    App.contracts.BOTToken.deployed().then(function(instance) {
    })
  },

  bindEvents: function() {
    $(document).on('click', '.buy-number-btn', App.buyNumber);
  },

  buyNumber: function() {

  }
};

$(function() {
  $(window).load(function() {
    App.init();
  });
});
