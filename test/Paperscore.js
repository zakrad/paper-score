const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
require("@nomiclabs/hardhat-ethers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const fs = require("fs")
const path = require("path")

describe("PaperScore", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployAll() {
    const [deployer, authorCreator] = await ethers.getSigners();
    const Deployer = deployer.address;
    const Reviewer = await ethers.getContractFactory("Review");
    // const paperscore = await upgrades.deployProxy(PaperScore);
    const reviewer = await Reviewer.deploy();

    await reviewer.deployed();
    const revieweraddress = reviewer.address;

    const AccessMinter = await ethers.getContractFactory("AccessMinter");
    const accessminter = await AccessMinter.deploy();
    await accessminter.deployed();
    const accessminteraddress = accessminter.address;

    const AuthorFactory = await ethers.getContractFactory("AuthorFactory");
    const authorfactory = await AuthorFactory.deploy(accessminter.address, Deployer);
    await authorfactory.deployed();
    const authorfactoryaddress = authorfactory.address;

    const Author = await ethers.getContractFactory("Author");
    const author = await Author.deploy();
    await author.deployed();

    const dir = path.resolve(
      __dirname,
      "../artifacts/contracts/Author.sol/Author.json"
    )
    const file = fs.readFileSync(dir, "utf8")
    const json = JSON.parse(file)
    const authorAbi = json.abi;

    await authorfactory.connect(authorCreator).createAuthor();
    const [author1] = await authorfactory.getAuthors();
    const clonedAuthor = new ethers.Contract(author1, authorAbi, authorCreator);

    return { reviewer, accessminter, authorfactory, revieweraddress, accessminteraddress, authorfactoryaddress, Deployer, deployer, authorAbi, clonedAuthor, authorCreator };
  }

  describe("Author: Deployment", function () {
    it("Should set the right Admin", async function () {
      const { deployer, Deployer } = await loadFixture(deployAll);
      expect(deployer.address).to.equal(Deployer);
    });
    it("Should create proxy with sender address as author", async function () {
      const [account2] = await ethers.getSigners();
      const { authorfactory, authorAbi } = await loadFixture(deployAll);
      await authorfactory.connect(account2).createAuthor();
      const [author1, author2] = await authorfactory.getAuthors();
      const clonedAuthor = new ethers.Contract(author2, authorAbi, account2);
      const keccAuthor = ethers.utils.keccak256(ethers.utils.toUtf8Bytes("AUTHOR"));
      const checkRole = await clonedAuthor.hasRole(keccAuthor, account2.address);
      expect(checkRole).to.equal(true);
    });
    it("Should create proxy with admin address as admin AND uri SETTER", async function () {
      const [account2] = await ethers.getSigners();
      const { authorfactory, authorAbi, Deployer } = await loadFixture(deployAll);
      await authorfactory.connect(account2).createAuthor();
      const [author1] = await authorfactory.getAuthors();
      const clonedAuthor = new ethers.Contract(author1, authorAbi, account2);
      const keccUri = ethers.utils.keccak256(ethers.utils.toUtf8Bytes("URI_SETTER_ROLE"));
      const keccAdmin = ethers.utils.keccak256(ethers.utils.toUtf8Bytes("DEFAULT_ADMIN_ROLE"));
      const checkRole = await clonedAuthor.hasRole(keccUri, Deployer);
      const adminRole = await clonedAuthor.getRoleAdmin(keccAdmin);
      const checkAdmin2 = await clonedAuthor.hasRole(adminRole, Deployer);
      expect(checkRole).to.equal(true);
      expect(checkAdmin2).to.equal(true);
    });
    it("Initialize again Should revert with 'Initializable: contract is already initialized'", async function () {
      const [account2] = await ethers.getSigners();
      const { authorfactory, authorAbi, Deployer } = await loadFixture(deployAll);
      await authorfactory.connect(account2).createAuthor();
      const [author1] = await authorfactory.getAuthors();
      const clonedAuthor = new ethers.Contract(author1, authorAbi, account2);
      await expect(clonedAuthor.initialize(Deployer, 'https', Deployer, Deployer)).to.be.revertedWith('Initializable: contract is already initialized')
    });
  });

  describe("Author: Functions", function () {
    it("Submit paper emits event ", async function () {
      const { clonedAuthor, authorCreator } = await loadFixture(deployAll);
      const paper = await clonedAuthor.connect(authorCreator).submitPaper('A1', 'hash1', []);
      console.log(paper);
      // expect(deployer.address).to.equal(Deployer);
    });
  });

  describe("deployProxy", function () {

  });

  // describe("Withdrawals", function () {
  //   describe("Validations", function () {
  //     it("Should revert with the right error if called too soon", async function () {
  //       const { lock } = await loadFixture(deployOneYearLockFixture);

  //       await expect(lock.withdraw()).to.be.revertedWith(
  //         "You can't withdraw yet"
  //       );
  //     });

  //     it("Should revert with the right error if called from another account", async function () {
  //       const { lock, unlockTime, otherAccount } = await loadFixture(
  //         deployOneYearLockFixture
  //       );

  //       // We can increase the time in Hardhat Network
  //       await time.increaseTo(unlockTime);

  //       // We use lock.connect() to send a transaction from another account
  //       await expect(lock.connect(otherAccount).withdraw()).to.be.revertedWith(
  //         "You aren't the owner"
  //       );
  //     });

  //     it("Shouldn't fail if the unlockTime has arrived and the owner calls it", async function () {
  //       const { lock, unlockTime } = await loadFixture(
  //         deployOneYearLockFixture
  //       );

  //       // Transactions are sent using the first signer by default
  //       await time.increaseTo(unlockTime);

  //       await expect(lock.withdraw()).not.to.be.reverted;
  //     });
  //   });

  //   describe("Events", function () {
  //     it("Should emit an event on withdrawals", async function () {
  //       const { lock, unlockTime, lockedAmount } = await loadFixture(
  //         deployOneYearLockFixture
  //       );

  //       await time.increaseTo(unlockTime);

  //       await expect(lock.withdraw())
  //         .to.emit(lock, "Withdrawal")
  //         .withArgs(lockedAmount, anyValue); // We accept any value as `when` arg
  //     });
  //   });

  //   describe("Transfers", function () {
  //     it("Should transfer the funds to the owner", async function () {
  //       const { lock, unlockTime, lockedAmount, owner } = await loadFixture(
  //         deployOneYearLockFixture
  //       );

  //       await time.increaseTo(unlockTime);

  //       await expect(lock.withdraw()).to.changeEtherBalances(
  //         [owner, lock],
  //         [lockedAmount, -lockedAmount]
  //       );
  //     });
  //   });
  // });
});
