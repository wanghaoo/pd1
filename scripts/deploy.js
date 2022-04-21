const { task } = require("hardhat/config");
const { getAccount } = require("./helpers");

task("deploy", "Deploys the PD1Certificate.sol contract")
.setAction(async function (taskArguments, hre) {
    const nftContractFactory = await hre.ethers.getContractFactory("PD1Certificate", getAccount());
    const nft = await nftContractFactory.deploy();
    console.log(`Contract deployed to address: ${nft.address}`);
});