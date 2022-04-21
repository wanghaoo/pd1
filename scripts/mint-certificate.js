const { task } = require("hardhat/config");
const { getContract } = require("./helpers");

//0x408B8d1EbeBF2fDD0E9492091Afd5A6AFEa71DB2
task("issuingOfCertificates", "issuing of certificates")
.addParam("address", "The 721 contract address")
.addParam("holderAddress", "The certificate holder address")
.addParam("tokenId", "The 721 contract token id")
.setAction(async function (taskArguments, hre) {
    const contract = await getContract("PD1Certificate", hre);
    const transactionResponse = await contract.issuingOfCertificates(taskArguments.address, taskArguments.holderAddress, taskArguments.tokenId, {
        gasLimit: 500_000,
    });
    console.log(`Transaction Hash: ${transactionResponse.hash}`);
});

task("clearCertificatesHolder", "set token certificate holder")
.addParam("address", "The 721 contract address")
.addParam("tokenId", "The 721 contract token id")
.setAction(async function (taskArguments, hre) {
    const contract = await getContract("PD1Certificate", hre);
    const transactionResponse = await contract.clearCertificatesHolder(taskArguments.address, taskArguments.tokenId, {
        gasLimit: 500_000,
    });
    console.log(`Transaction Hash: ${transactionResponse.hash}`);
});

task("ownerOf", "clear token certificate holder")
.addParam("address", "The 721 contract address")
.addParam("tokenId", "The 721 contract token id")
.setAction(async function (taskArguments, hre) {
    const contract = await getContract("PD1Certificate", hre);
    const transactionResponse = await contract.ownerOf(taskArguments.address, taskArguments.tokenId, {
        gasLimit: 500_000,
    });
    console.log(`Transaction Hash: ${transactionResponse.hash}`);
});

task("getTokenOwner", "get 721 token owner")
.addParam("address", "The 721 contract address")
.addParam("tokenId", "The 721 contract token id")
.setAction(async function (taskArguments, hre) {
    const contract = await getContract("PD1Certificate", hre);
    const transactionResponse = await contract.getTokenOwner(taskArguments.address, taskArguments.tokenId, {
        gasLimit: 500_000,
        value:10000,
    });
    console.log(`Transaction Hash: ${transactionResponse.hash}`);
});
