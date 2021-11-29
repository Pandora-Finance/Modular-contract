const NFTBid = artifacts.require('NFTBid');

module.exports = async function (deployer) {
  // const instance = await deployProxy(NFTMarketplace, {deployer, initializer: 'initialize'});
  // await deployProxy(NFTMarketplace,{deployer, initializer: 'initialize'});
  // console.log('Deployed', instance.address);
    deployer.deploy(NFTBid);
};
 