import { ethers } from "hardhat";
import * as fs from "node:fs";

async function main() {
  const MyERC20 = await ethers.getContractFactory("MyERC20");
  const myERC20 = await MyERC20.deploy(100_000_000);

  await myERC20.deployed();

  console.log("myERC20 deployed to:", myERC20.address);

  const ownerAddress = await myERC20.signer.getAddress();

  fs.writeFileSync(
    "./config.js",
    `
  export const contractAddress = "${myERC20.address}"
  export const ownerAddress = "${ownerAddress}"
  `
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
