require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-waffle");
require("hardhat-change-network");
require("hardhat-gas-reporter");
require("solidity-coverage");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();


  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  defaultNetwork: "matic",
  networks: {
    hardhat: {
      chainId: 1337,
      forking: {
        url: "https://polygon-mumbai.g.alchemy.com/v2/YjcosiVtN_13wfT3A1R1blPTKKYfP6ne"
      }
    },
    localhost: {
      url: "http://127.0.0.1:8545",
      accounts: ["57abfe0526154677c2a71f535b694aeb88a8f85656055c40817a6919cffe596e"],
      gas: 1
    },
     matic: {
      url: "https://rpc-mumbai.maticvigil.com",
      accounts: ["57abfe0526154677c2a71f535b694aeb88a8f85656055c40817a6919cffe596e"],
      gas: 1
     },
    //   goerli: {
    //     url: "https://goerli.infura.io/v3/22dfda9e0fa94535be0ab1e961562169",
    //     accounts:[""],
    //     },//
  },
  solidity: {
    compilers: [
      {
        version: "0.8.4",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          }
        },
      },
    ],
  },
  paths: {
    sources: "./contracts/",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  // gasReporter: {
  //   enabled: process.env.REPORT_GAS !== undefined,
  //   currency: "USD",
  // },
  etherscan: {
    apiKey: "8VS2IWJGJK4MN4ZHFJFR9RHWMFWC8U12DH",
  },
};