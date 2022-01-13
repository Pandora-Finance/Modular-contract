// const { deployProxy } = require("@openzeppelin/truffle-upgrades");
const LibShare = artifacts.require("LibShare");
const LibERC721 = artifacts.require("LibERC721");
const TokenERC721 = artifacts.require("LibERC721");
const TokenFactory = artifacts.require("TokenFactory");
const PNDC_ERC721 = artifacts.require("PNDC_ERC721");

module.exports = function (deployer) {
  deployer.deploy(LibShare).then((res) => console.log("LibShare", res.address));

  deployer.link(LibShare, TokenERC721);
  deployer.link(LibShare, LibERC721);
  deployer.link(LibShare, PNDC_ERC721);

  deployer.deploy(PNDC_ERC721,"NFT","NFT").then((res) => console.log('PNDC_ERC721', res.address));
  deployer
    .deploy(LibERC721)
    .then((res) => console.log("LibERC721", res.address));

  deployer.link(LibERC721, TokenFactory);
  deployer
    .deploy(TokenFactory)
    .then((res) => console.log("Factory", res.address));

  // deployProxy(TokenFactory, {
  //     kind: "uups",
  //     unsafeAllow: ["external-library-linking"],
  //   })
  //   .then((res) => console.log("Factory", res.address));
};
