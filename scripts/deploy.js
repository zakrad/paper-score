// const { ethers, upgrades } = require("hardhat");

async function main() {

  const PaperScore = await hre.ethers.getContractFactory("PaperScore");
  // const paperscore = await upgrades.deployProxy(PaperScore);
  const paperscore = await PaperScore.deploy()

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

// 0x5FbDB2315678afecb367f032d93F642f64180aa3
