// const NFTMint = artifacts.require("NFTMint");
const NFTBid = artifacts.require("NFTBid");
const TokenFactory = artifacts.require("TokenFactory");
const LibBid = artifacts.require("LibBid");
const LibMeta = artifacts.require("LibMeta");
const LibShare = artifacts.require("LibShare");
const LibERC721 = artifacts.require("LibERC721")
const LibCollection = artifacts.require("LibCollection")
const NFTFactoryContract = artifacts.require("NFTFactoryContract");
const NFTStorage = artifacts.require("NFTV1Storage");
const PNDC_ERC721 = artifacts.require("PNDC_ERC721");

module.exports = async function (deployer) {
  // const instance = await deployProxy(NFTMarketplace, {deployer, initializer: 'initialize'});
  // await deployProxy(NFTMarketplace,{deployer, initializer: 'initialize'});
  // console.log('Deployed', instance.address);
  deployer.deploy(LibBid);
  deployer.deploy(LibMeta);
  deployer.deploy(LibShare);
  deployer.deploy(LibERC721);
  deployer.deploy(LibCollection);

  deployer.link(LibShare, PNDC_ERC721);
  deployer.deploy(PNDC_ERC721, "NFT", "NFT");

  deployer.link(LibMeta, NFTStorage);
  deployer.link(LibBid, NFTStorage);
  deployer.link(LibCollection, NFTStorage);
  deployer.link(LibShare, NFTFactoryContract);
  deployer.link(LibBid, NFTBid);
  deployer.link(LibMeta, NFTBid);
  deployer.link(LibERC721, TokenFactory);
  deployer.link(LibCollection, TokenFactory);
  deployer.link(LibMeta, TokenFactory)
  deployer.deploy(TokenFactory);

};
