const { deployProxy } = require("@openzeppelin/truffle-upgrades");
require('dotenv').config();

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
const ProxyMarketplaceFactory = artifacts.require("ProxyMarketplaceFactory");

module.exports = async function (deployer) {
  await deployer.deploy(LibMeta);
  await deployer.link(LibMeta, [NFTStorage, NFTBid, TokenFactory]);

  await deployer.deploy(LibRoyalty);
  await deployer.link(LibRoyalty, [NFTFactoryContract, NFTBid, TokenFactory]);

  await deployer.deploy(LibERC721);
  await deployer.link(LibERC721, TokenFactory);

  await deployer.deploy(PNDC_ERC721, "NFT", "NFT");
  var pndc = await PNDC_ERC721.deployed();

  let result = 0;
  
  await deployProxy(TokenFactory, [pndc.address, process.env.FEE_ADDRESS], {
    kind: "uups",
    unsafeAllow: ["external-library-linking"],
  }).then((res) => {
    result = res.address;
    console.log("Factory", res.address);
  });

  result = await TokenFactory.deployed();
  let addr = await result.getImplementation();
  console.log("Factory implementation", addr);

  let factory = await TokenFactory.at(addr);
  await factory.initialize(pndc.address, "0xE850d0221BE67813D47EfF75E62684E679623093");

  await deployer.deploy(ProxyMarketplaceFactory, addr);
  const instance = await ProxyMarketplaceFactory.deployed();
  console.log("Cloning contract: ", instance.address);

  console.log("PNDC", pndc.address);

};
