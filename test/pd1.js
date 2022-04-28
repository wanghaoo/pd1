// const { expect } = require("chai");
// const { ethers } = require("hardhat");

// describe("PD1", function () {
//   it("Should return the new PD1 once it's changed", async function () {
//     const PD1 = await ethers.getContractFactory("PD1");
//     const pd1 = await PD1.deploy("Caspid", "PD1", "https://bafkreifm6bjjok7v36xqhwld6vrifqsn4g44rhqx3zyvxh2wqcx67sko44.ipfs.nftstorage.link/");
//     await pd1.deployed();

//     await pd1.mint("0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266");
//     await pd1.mint("0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266");

//     expect(await pd1.balanceOf("0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266")).to.equal(2);


//     await pd1.setTokenCertificateHolder("0x7F8595902Dde158B56010Ed9074E06bd2B64A70d", 1);
//     expect(await pd1.getHolder("0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266", 1)).to.equal("0x7F8595902Dde158B56010Ed9074E06bd2B64A70d");
//     expect(await pd1.hasHoldToken("0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266", "0x7F8595902Dde158B56010Ed9074E06bd2B64A70d", 1)).to.equal(true);

//     await pd1.clearTokenCertificateHolder(1);
//     expect(await pd1.getHolder("0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266", 1)).to.equal("0x0000000000000000000000000000000000000000");
//     expect(await pd1.hasHoldToken("0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266", "0x7F8595902Dde158B56010Ed9074E06bd2B64A70d", 1)).to.equal(false);

//     await pd1.transfer("0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266", "0x7F8595902Dde158B56010Ed9074E06bd2B64A70d", 1);
//     expect(await pd1.balanceOf("0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266")).to.equal(1);
//     expect(await pd1.balanceOf("0x7F8595902Dde158B56010Ed9074E06bd2B64A70d")).to.equal(1);

//   });
// });
