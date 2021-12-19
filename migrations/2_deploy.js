const { deployProxy } = require("@openzeppelin/truffle-upgrades");

const NFTBid = artifacts.require("NFTBid");
const TokenFactory = artifacts.require("TokenFactory");
const LibBid = artifacts.require("LibBid");
const LibMeta = artifacts.require("LibMeta");
const LibShare = artifacts.require("LibShare");
const LibERC721 = artifacts.require("LibERC721");
const LibCollection = artifacts.require("LibCollection");
const NFTFactoryContract = artifacts.require("NFTFactoryContract");
const NFTStorage = artifacts.require("NFTV1Storage");
const PNDC_ERC721 = artifacts.require("PNDC_ERC721");

module.exports = async function (deployer) {
  await deployer.deploy(LibMeta);
  await deployer.link(LibMeta, [NFTStorage, NFTBid, TokenFactory]);
  await deployer.deploy(LibERC721);
  await deployer.link(LibERC721, TokenFactory);
  await deployer.deploy(PNDC_ERC721, "NFT", "NFT");
  // await deployer.deploy(TokenFactory);
  await deployProxy(TokenFactory, {
    kind: "uups",
    unsafeAllow: ["external-library-linking"],
  }).then((res) => console.log("Factory", res.address));
};
