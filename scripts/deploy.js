const { ethers, upgrades } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  const Reviewer = await ethers.getContractFactory("Review");
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

  const AuthorFactory = await ethers.getContractFactory("AuthorFactory");
  const authorfactory = await AuthorFactory.deploy(accessminter.address, deployer.address);
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

  // REVIEWER deployed to 0x5FbDB2315678afecb367f032d93F642f64180aa3
  // accessminter deployed to 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512
  // authorfactory deployed to 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0