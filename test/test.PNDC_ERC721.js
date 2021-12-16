
const PNDC_ERC721 = artifacts.require("PNDC_ERC721");
contract("PNDC_ERC721", (accounts) => {
 describe("Testing PNDC_ERC721 Workflow ", function(){ 
  it("Testing smart contract function safeMint()", async () => {
    const instance = await PNDC_ERC721.deployed();

    result = await instance.safeMint(accounts[0],"URI",[[accounts[0],500]]);
   
    assert.equal(result.receipt.logs[0].type, "mined", "Failed to mint");
  });  
  

 })
 
});
