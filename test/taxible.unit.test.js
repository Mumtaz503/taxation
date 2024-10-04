const { getNamedAccounts, ethers, deployments } = require("hardhat");
const { developmentChains } = require("../helper-hardhat.config");

!developmentChains.includes(network.name)
  ? describe.skip
  : describe("Taxible Unit tests", function () {
      let taxible, deployer, deployerSigner, user, signer, userSigner, routerV2;

      beforeEach(async function () {
        deployer = (await getNamedAccounts()).deployer;
        deployerSigner = await ethers.provider.getSigner(deployer);
        user = (await getNamedAccounts()).user;
        signer = await ethers.provider.getSigner();
        userSigner = await ethers.getSigner(user);
        await deployments.fixture(["all"]);
        taxible = await ethers.getContract("Taxible", deployer);
        routerV2 = await ethers.getContractAt(
          "UniswapV2Router02",
          "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D",
          signer
        );
      });

      describe("enableTrading function", function () {
        it("Should send that transaction", async function () {
          const tx = await deployerSigner.sendTransaction({
            to: taxible.target,
            value: ethers.parseEther("50"),
          });
          await tx.wait(1);

          const deployerBalance = await taxible.balanceOf(deployer);
          const tx2 = await taxible.transfer(taxible.target, deployerBalance);
          await tx2.wait(1);

          const transactionResponse = await taxible
            .connect(deployerSigner)
            .enableTrading();
          const transactionReciept = await transactionResponse.wait(1);
        });
      });
    });
