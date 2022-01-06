const { deployProxy } = require("@openzeppelin/truffle-upgrades");

const NFTBid = artifacts.require("NFTBid");
const NFTBid1155 = artifacts.require("NFTBid1155");
const TokenFactory = artifacts.require("TokenFactory");
const TokenFactory1155 = artifacts.require("TokenFactory1155");
const LibBid = artifacts.require("LibBid");
const LibMeta = artifacts.require("LibMeta");
const LibMeta1155 = artifacts.require("LibMeta1155")
const LibShare = artifacts.require("LibShare");
const LibERC721 = artifacts.require("LibERC721");
const LibERC1155 = artifacts.require("LibERC1155");
const LibCollection = artifacts.require("LibCollection");
const NFTFactoryContract = artifacts.require("NFTFactoryContract");
const NFTStorage = artifacts.require("NFTV1Storage");
const NFTStorage1155 = artifacts.require("NFTV1Storage1155");
const PNDC_ERC721 = artifacts.require("PNDC_ERC721");
const PNDC_ERC1155 = artifacts.require("PNDC_ERC1155");

module.exports = async function (deployer) {
  await deployer.deploy(LibMeta);
  await deployer.link(LibMeta, [NFTStorage, NFTBid, TokenFactory]);

  await deployer.deploy(LibERC721);
  await deployer.link(LibERC721, TokenFactory);

  await deployer.deploy(PNDC_ERC721, "NFT", "NFT");
  var pndc = await PNDC_ERC721.deployed();
  
  await deployProxy(TokenFactory, [pndc.address], {
    kind: "uups",
    unsafeAllow: ["external-library-linking"],
  }).then((res) => console.log("Factory", res.address));
  console.log("PNDC", pndc.address);
  
  //1155

  await deployer.deploy(LibMeta1155);
  await deployer.link(LibMeta1155, [NFTStorage1155, NFTBid1155, TokenFactory1155]);

  await deployer.deploy(LibERC1155);
  await deployer.link(LibERC1155, TokenFactory1155);

  await deployer.deploy(PNDC_ERC1155, "NFT");
  var pndc1155 = await PNDC_ERC1155.deployed();
  
  await deployProxy(TokenFactory1155, [pndc1155.address], {
    kind: "uups",
    unsafeAllow: ["external-library-linking"],
  }).then((res) => console.log("Factory1155", res.address));
  console.log("PNDC1155", pndc1155.address);
};
