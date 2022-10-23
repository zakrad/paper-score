const { ethers, upgrades } = require("hardhat");

async function main() {

  const PaperScore = await hre.ethers.getContractFactory("PaperScore");
  const paperscore = await upgrades.deployProxy(PaperScore);

  await paperscore.deployed();

  console.log(
    `deployed to ${paperscore.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });

//
