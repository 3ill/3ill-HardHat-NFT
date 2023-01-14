require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
require("solidity-coverage");
require("hardhat-deploy");
require("hardhat-gas-reporter");
const { GOERLI_URL, PRIVATE_KEY, ETHERSCAN_API, COINMARKETCAP_API } = process.env;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
  defaultNetwork: "hardhat",
  networks: {
    goerli: {
      url: GOERLI_URL,
      accounts: [`0x${PRIVATE_KEY}`],
      chainId: 5,
      blockConfirmations: 1,
    },
    hardhat: {
      chainId: 31337,
      blockConfirmations: 5,
    },
  },

  etherscan: {
    apiKey: ETHERSCAN_API,
  },
  namedAccounts: {
    deployer: {
      default: 0,
    },
    user: {
      default: 1,
    },
  },
  gasReporter: {
    enabled: false,
    outputFile: "gasReport.txt",
    noColors: true,
    currency: "USD",
    coinmarketcap: COINMARKETCAP_API,
    token: "MATIC"
  }
};
