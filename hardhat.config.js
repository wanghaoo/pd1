require('@nomiclabs/hardhat-waffle');
require('@nomiclabs/hardhat-etherscan');
require('hardhat-gas-reporter');
require("./scripts/deploy.js");
// require("./scripts/mint-certificate.js");

const dotenv = require('dotenv');

dotenv.config();

/**
 * @type import('hardhat/config').HardhatUserConfig
 */

const { API_URL, PRIVATE_KEY, ETHERSCAN_API_KEY } = process.env;

module.exports = {
  solidity: '0.8.4',
  defaultNetwork:"hardhat",
  networks: {
    hardhat: {
    },
    // rinkeby: {
    //   url: API_URL,
    //   accounts: [PRIVATE_KEY],
    // },
    // mainnet: {
    //   url: API_URL,
    //   accounts: [PRIVATE_KEY],
    // },
  },
  // etherscan: {
  //   apiKey: ETHERSCAN_API_KEY,
  // },
  mocha: {
    timeout: 80000
  }
};
