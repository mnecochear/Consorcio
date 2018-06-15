module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*"
    },
    ropsten:  {
      network_id: 3,
      host: "localhost",
      port:  8545,
      //from: "",
      gas:   2900000
    }
  },
  rpc: {
    host: 'localhost',
    port: 8080
  }
};
