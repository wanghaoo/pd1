const { task } = require("hardhat/config");
const { getContract } = require("./helpers");

task("mint", "Mints from the NFT contract")
.addParam("address", "The address to receive a token")
.setAction(async function (taskArguments, hre) {
    const contract = await getContract("PD1", hre);
    const transactionResponse = await contract.mint(taskArguments.address, {
        gasLimit: 500_000,
    });
    console.log(`Transaction Hash: ${transactionResponse.hash}`);
});

task("setTokenCertificateHolder", "set token certificate holder")
.addParam("holder", "The address to holder")
.addParam("tokenId", "The token to set")
.setAction(async function (taskArguments, hre) {
    const contract = await getContract("PD1", hre);
    const transactionResponse = await contract.setTokenCertificateHolder(taskArguments.holder, taskArguments.tokenId, {
        gasLimit: 500_000,
    });
    console.log(`Transaction Hash: ${transactionResponse.hash}`);
});

task("clearTokenCertificateHolder", "clear token certificate holder")
.addParam("tokenId", "The token to clear")
.setAction(async function (taskArguments, hre) {
    const contract = await getContract("PD1", hre);
    const transactionResponse = await contract.clearTokenCertificateHolder(taskArguments.tokenId, {
        gasLimit: 500_000,
    });
    console.log(`Transaction Hash: ${transactionResponse.hash}`);
});

task("getHolder", "get token certificate holder")
.addParam("owner", "The address to owner")
.addParam("tokenId", "The token to owner")
.setAction(async function (taskArguments, hre) {
    const contract = await getContract("PD1", hre);
    const transactionResponse = await contract.getHolder(taskArguments.owner, taskArguments.tokenId, {
        gasLimit: 500_000,
    });
    console.log(`Transaction Hash: ${transactionResponse.hash}`);
});

task("hasHoldToken", "judge the token certificate")
.addParam("owner", "The address to owner")
.addParam("holder", "The address to holder")
.addParam("tokenId", "The token to owner")
.setAction(async function (taskArguments, hre) {
    const contract = await getContract("PD1", hre);
    const transactionResponse = await contract.hasHoldToken(taskArguments.owner, taskArguments.holder, taskArguments.tokenId, {
        gasLimit: 500_000,
    });
    console.log(`Transaction Hash: ${transactionResponse.hash}`);
});


task("transfer", "tranfer the token")
.addParam("from", "The address to owner")
.addParam("to", "The address to transfer")
.addParam("tokenId", "The token to owner")
.setAction(async function (taskArguments, hre) {
    const contract = await getContract("PD1", hre);
    const transactionResponse = await contract.transfer(taskArguments.from, taskArguments.to, taskArguments.tokenId, {
        gasLimit: 500_000,
    });
    console.log(`Transaction Hash: ${transactionResponse.hash}`);
});

task("balanceOf", "get own token number")
.addParam("owner", "The address to owner")
.setAction(async function (taskArguments, hre) {
    const contract = await getContract("PD1", hre);
    const transactionResponse = await contract.balanceOf(taskArguments.owner, {
        gasLimit: 500_000,
    });
    console.log(`Transaction Hash: ${transactionResponse.hash}`);
});