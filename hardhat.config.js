require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

module.exports = {
  solidity: "0.8.4",
  etherscan: {
    apiKey: "GCXMV12DUGHRCJGSFIUH985EJP9EIC12F4"
  },
  networks: {
    kovan: {
      url: "https://kovan.infura.io/v3/f87b967bc65a41c0a1a25635493fa482",
      accounts: ["a690d61565965031979565096277265e256d464f06a23296cbc1984b0c690d9d"]
    }
  },
};
