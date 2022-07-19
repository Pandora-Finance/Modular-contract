const { deployProxy } = require("@openzeppelin/truffle-upgrades");

const NFTBid = artifacts.require("NFTBid");
const TokenFactory = artifacts.require("TokenFactory");
const LibBid = artifacts.require("LibBid");
const LibMeta = artifacts.require("LibMeta");
const LibRoyalty = artifacts.require("LibRoyalty");
const LibShare = artifacts.require("LibShare");
const LibERC721 = artifacts.require("LibERC721");
const LibCollection = artifacts.require("LibCollection");
const NFTFactoryContract = artifacts.require("NFTFactoryContract");
const NFTStorage = artifacts.require("NFTV1Storage");
const PNDC_ERC721 = artifacts.require("PNDC_ERC721");

module.exports = async function (deployer) {
  await deployer.deploy(LibMeta);
  await deployer.link(LibMeta, [NFTStorage, NFTBid, TokenFactory]);

  await deployer.deploy(LibRoyalty);
  await deployer.link(LibRoyalty, [NFTFactoryContract, NFTBid, TokenFactory]);

  await deployer.deploy(LibERC721);
  await deployer.link(LibERC721, TokenFactory);

  await deployer.deploy(PNDC_ERC721, "NFT", "NFT");
  var pndc = await PNDC_ERC721.deployed();
  
  await deployProxy(TokenFactory, [pndc.address, "0x96108c628315971BF1bB2f154e23cc5552eA4AdD"], {
    kind: "uups",
    unsafeAllow: ["external-library-linking"],
  }).then((res) => console.log("Factory", res.address));
  console.log("PNDC", pndc.address);

};
