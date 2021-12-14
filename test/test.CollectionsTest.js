
const TokenERC721 = artifacts.require("TokenERC721");
contract("TokenERC721", (accounts) => {
 describe("Testing TokenERC721 Workflow ", function(){ 
  it("Testing smart contract function mintNFT() that mints NFT : Test 2", async () => {
    const instance = await TokenERC721.deployed();
   
    assert.equal(result.receipt.logs[0].type, "mined", "Failed to mint");
  });  
  

 })
 
});
