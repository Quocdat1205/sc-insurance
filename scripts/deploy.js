const hre = require("hardhat");

async function main() {
  const Insurance = await hre.ethers.getContractFactory("Insurance");
  const insurance = await Insurance.deploy();

  await insurance.deployed();

  console.log("Insurance contract address: ", insurance.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
