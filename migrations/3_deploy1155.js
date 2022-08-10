const { deployProxy } = require("@openzeppelin/truffle-upgrades");
require('dotenv').config();

const NFTBid1155 = artifacts.require("NFTBid1155");
const TokenFactory1155 = artifacts.require("TokenFactory1155");
const LibRoyalty = artifacts.require("LibRoyalty");
const LibMeta1155 = artifacts.require("LibMeta1155")
const LibERC1155 = artifacts.require("LibERC1155");
const LibCollection = artifacts.require("LibCollection");
const NFTFactoryContract1155 = artifacts.require("NFTFactoryContract1155");
const NFTStorage1155 = artifacts.require("NFTV1Storage1155");
const PNDC_ERC1155 = artifacts.require("PNDC_ERC1155");
const proxyMarketplace1155Factory = artifacts.require("ProxyMarketplace1155Factory");

module.exports = async function (deployer) {

  await deployer.deploy(LibMeta1155);
  await deployer.link(LibMeta1155, [NFTStorage1155, NFTBid1155, TokenFactory1155]);

  await deployer.deploy(LibERC1155);
  await deployer.link(LibERC1155, TokenFactory1155);

  await deployer.deploy(LibRoyalty);
  await deployer.link(LibRoyalty, [NFTFactoryContract1155, NFTBid1155, TokenFactory1155]);

  await deployer.deploy(PNDC_ERC1155, "NFT");
  var pndc1155 = await PNDC_ERC1155.deployed();
  
  await deployProxy(TokenFactory1155, [pndc1155.address, process.env.FEE_ADDRESS], {
    kind: "uups",
    unsafeAllow: ["external-library-linking"],
  }).then((res) => console.log("Factory1155", res.address));

  result = await TokenFactory1155.deployed();
  let addr = await result.getImplementation();
  console.log("Factory implementation", addr);

  let factory1155 = await TokenFactory1155.at(addr);
  await factory1155.initialize(pndc1155.address, "0xE850d0221BE67813D47EfF75E62684E679623093");

  await deployer.deploy(proxyMarketplace1155Factory, addr);
  const instance = await proxyMarketplace1155Factory.deployed();
  console.log("1155 Cloning contract: ", instance.address);

  console.log("PNDC1155", pndc1155.address);
};