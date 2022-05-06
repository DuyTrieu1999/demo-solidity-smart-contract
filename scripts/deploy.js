const hre = require("hardhat");
const fs = require('fs');

async function main() {
  const NFTMarketplace = await hre.ethers.getContractFactory("NFTMarketplace");
  const nftMarket = await NFTMarketplace.deploy();

  await nftMarket.deployed();

  console.log("NFT market deployed to:", nftMarket.address);

  const NFT = await hre.ethers.getContractFactory("NFT");
  const nft = await NFT.deploy(nftMarket.address);

  await nft.deployed();

  console.log("NFT deployed to:", nft.address);

  fs.writeFileSync('./config.js', `
  export const nftMarketAddress = "${nftMarket.address}"
  `)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
