import { ethers } from "hardhat";
import { expect } from "chai";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";

describe("ERC20_2", async function () {
  async function getERC20() {
    const ERC20 = await ethers.getContractFactory("MyERC20_2");
    const myERC20 = await ERC20.deploy(100_000_000);
    await myERC20.deployed();

    return myERC20;
  }

  async function getDeployerAddress() {
    const [deployer] = await ethers.getSigners();
    const deployerAddress = await deployer.getAddress();

    return deployerAddress;
  }

  it("totalSupply", async function () {
    const myERC20 = await loadFixture(getERC20);
    const totalSupply = await myERC20.totalSupply();
    expect(totalSupply).to.equal(100_000_000);
  });

  it("ownerBalance", async function () {
    const myERC20 = await loadFixture(getERC20);
    const deployerAddress = await loadFixture(getDeployerAddress);
    const balance = await myERC20.balanceOf(deployerAddress);
    expect(balance).to.equal(100_000_000);
  });

  it("transfer", async function () {
    const myERC20 = await loadFixture(getERC20);
    await myERC20.transfer(
      "0xD4f31B7579C21F846C4881226871FA31e0E4ea44",
      50_000_000
    );
    const balance = await myERC20.balanceOf(
      "0xD4f31B7579C21F846C4881226871FA31e0E4ea44"
    );
    expect(balance).to.equal(50_000_000);
  });

  it("burn", async function () {
    const myERC20 = await loadFixture(getERC20);
    const deployerAddress = await loadFixture(getDeployerAddress);
    await myERC20.burn(50_000_000);
    const balance = await myERC20.balanceOf(deployerAddress);
    const totalSupply = await myERC20.totalSupply();
    expect(balance).to.equal(50_000_000);
    expect(totalSupply).to.equal(50_000_000);
  });

  it("blacklist", async function () {
    const myERC20 = await loadFixture(getERC20);

    await myERC20.blacklist("0xD4f31B7579C21F846C4881226871FA31e0E4ea44", true);
    await myERC20.transfer(
      "0xD4f31B7579C21F846C4881226871FA31e0E4ea44",
      10_000_000
    );
  });
});
