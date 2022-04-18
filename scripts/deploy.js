const { task } = require("hardhat/config");
const { getAccount } = require("./helpers");

task("deploy", "Deploys the PD1.sol contract")
.setAction(async function (taskArguments, hre) {
    const nftContractFactory = await hre.ethers.getContractFactory("PD1", getAccount());
    const nft = await nftContractFactory.deploy("Caspid", "PD1", "https://bafkreifm6bjjok7v36xqhwld6vrifqsn4g44rhqx3zyvxh2wqcx67sko44.ipfs.nftstorage.link/");
    console.log(`Contract deployed to address: ${nft.address}`);
});