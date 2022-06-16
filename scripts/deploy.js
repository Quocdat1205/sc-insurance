const hre = require("hardhat");

async function main() {
  const Insurance = await hre.ethers.getContractFactory("Insurance");
  const insurance = await Insurance.deploy(`0x0D17D1De09C0841c9E023A2a21Aa7eA8851B0fb8`);

  await insurance.deployed();

  console.log("Insurance contract address: ", insurance.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
