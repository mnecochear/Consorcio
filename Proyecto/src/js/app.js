App = {
  web3Provider: null,
  contracts: {},

  init: function() {
        // TODO funcion inicial
    return App.initWeb3();
  },

  initWeb3: function() {
	  // Is there an injected web3 instance?
	  if (typeof web3 !== 'undefined') {
	    App.web3Provider = web3.currentProvider;
	  } else {
	    // If no injected web3 instance is detected, fall back to Ganache
	    App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
	  }
	  web3 = new Web3(App.web3Provider);

    return App.initContract();
  },

  initContract: function() {
    $.getJSON('Consorcio.json', function(data) {
      // Get the necessary contract artifact file and instantiate it with truffle-contract
      var ConsorcioArtifact = data;
      App.contracts.Consorcio = TruffleContract(ConsorcioArtifact);

      // Set the provider for our contract
      App.contracts.Consorcio.setProvider(App.web3Provider);

      // Use our contract to do something useful
      // return App.someFunction;
    });

    return App.bindEvents();
  },

  bindEvents: function() {
    $(document).on('click', '#test-btn', App.getMembers);
    return App.setView();
  },

  setView: function() {
    var nameTextbox = document.createElement('input');
    var addMemberBtn = document.createElement('input');
    nameTextbox.id = 'textbox-fn';
    nameTextbox.type = 'text';
    nameTextbox.placeholder = 'Nombre';
    addMemberBtn.id = 'add-member-btn';
    addMemberBtn.type = 'button';
    addMemberBtn.value = 'Hacerme socio';
    document.getElementById('body').appendChild(nameTextbox);
    document.getElementById('body').appendChild(addMemberBtn);
    $(document).on('click', '#add-member-btn', App.addMember);
  },

  addMember: function() {
    var account = web3.eth.accounts[0];
    var consorcioInstance;
    var name = document.getElementById('textbox-fn').value;
    App.contracts.Consorcio.deployed().then(function(instance) {
      consorcioInstance = instance;
      // Agregar nuevo socio
      consorcioInstance.addMember(account, name).call();
    });
  },

  getMembers: function() {
    App.contracts.Consorcio.deployed().then(function(instance) {
      consorcioInstance = instance;
      return consorcioInstance.getMembers.call();
    }).then(function(names) {
      for (var i = 0; i < names.length; i++)
        console.log(web3.toAscii(names[i]));
    }).catch(function(err) {
      console.log(err.message);
    });
  }
};

$(function() {
  $(window).load(function() {
    App.init();
  });
});
