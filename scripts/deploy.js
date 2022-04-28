const { task } = require("hardhat/config");
const { getAccount } = require("./helpers");

task("deploy", "Deploys the PD1Permission.sol contract")
.setAction(async function (taskArguments, hre) {
    const nftContractFactory = await hre.ethers.getContractFactory("PD1Permission", getAccount());
    const nft = await nftContractFactory.deploy("PD1Permission", "CP");
    console.log(`Contract deployed to address: ${nft.address}`);
});