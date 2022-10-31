const { ethers, upgrades } = require("hardhat");

async function main() {

  const Reviewer = await ethers.getContractFactory("Reviewer");
  // const paperscore = await upgrades.deployProxy(PaperScore);
  const reviewer = await Reviewer.deploy();

  await reviewer.deployed();

  console.log(
    `REVIEWER deployed to ${reviewer.address}`
  );

  const AccessMinter = await ethers.getContractFactory("AccessMinter");
  const accessminter = await AccessMinter.deploy();
  await accessminter.deployed();

  console.log(
    `accessminter deployed to ${accessminter.address}`
  );

  const Author = await ethers.getContractFactory("Author");
  const author = await Author.deploy();
  await author.deployed();

  console.log(
    `author deployed to ${author.address}`
  );

  const AuthorFactory = await ethers.getContractFactory("AuthorFactory");
  const authorfactory = await AuthorFactory.deploy();
  await authorfactory.deployed();

  console.log(
    `authorfactory deployed to ${authorfactory.address}`
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
