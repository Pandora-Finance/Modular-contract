// const NFTMint = artifacts.require("NFTMint");
const NFTBid = artifacts.require("NFTBid");
const LibBid = artifacts.require("LibBid");
const LibMeta = artifacts.require("LibMeta");
const NFTFactoryContract = artifacts.require("NFTFactoryContract");

module.exports = async function (deployer) {
  // const instance = await deployProxy(NFTMarketplace, {deployer, initializer: 'initialize'});
  // await deployProxy(NFTMarketplace,{deployer, initializer: 'initialize'});
  // console.log('Deployed', instance.address);
  deployer.deploy(LibBid);
  deployer.deploy(LibMeta);
  // deployer.link(LibMeta, NFTMint);
  deployer.link(LibBid, NFTBid);
  deployer.link(LibMeta, NFTBid);
  deployer.link(LibMeta, NFTFactoryContract);
  deployer.deploy(NFTBid);
};
