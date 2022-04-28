const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("PD1Permission", function () {
  it("Should return the new PD1Permission it's changed", async function () {
    const PD1 = await ethers.getContractFactory("PD1Permission");
    const pd1 = await PD1.deploy("Caspid", "PD1");
    await pd1.deployed();

    await pd1.mint("0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266", "https://bafkreifm6bjjok7v36xqhwld6vrifqsn4g44rhqx3zyvxh2wqcx67sko44.ipfs.nftstorage.link/");

    expect(await pd1.balanceOf("0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266")).to.equal(1);

    expect(await pd1.access("0x70997970c51812dc3a010c7d01b50e0d17dc79c8", 0, 1)).to.equal(false);
    expect(await pd1.permission("0x70997970c51812dc3a010c7d01b50e0d17dc79c8", 0)).to.equal(0);

    await pd1.grant("0x70997970c51812dc3a010c7d01b50e0d17dc79c8", 0, 1, "好grant")

    expect(await pd1.access("0x70997970c51812dc3a010c7d01b50e0d17dc79c8", 0, 1)).to.equal(true);
    expect(await pd1.permission("0x70997970c51812dc3a010c7d01b50e0d17dc79c8", 0)).to.equal(1);

    await pd1.revoke("0x70997970c51812dc3a010c7d01b50e0d17dc79c8", 0)

    expect(await pd1.access("0x70997970c51812dc3a010c7d01b50e0d17dc79c8", 0, 1)).to.equal(false);
    expect(await pd1.permission("0x70997970c51812dc3a010c7d01b50e0d17dc79c8", 0)).to.equal(0);

    await pd1.grant("0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc", 0, 2, "好好好grant")

    expect(await pd1.access("0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc", 0, 2)).to.equal(true);
    expect(await pd1.permission("0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc", 0)).to.equal(2);

    await pd1.transferFrom("0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266", "0x90f79bf6eb2c4f870365e785982e1f101e93b906", 0)
    expect(await pd1.access("0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc", 0, 2)).to.equal(false);
    expect(await pd1.permission("0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc", 0)).to.equal(0);
  });
});
