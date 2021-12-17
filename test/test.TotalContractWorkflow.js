
const PNDC_ERC721 = artifacts.require("PNDC_ERC721");
const TokenFactory = artifacts.require("TokenFactory");
contract("PNDC_ERC721", (accounts) => {
  contract("TokenFactory", (accounts) => { 
 describe("Testing Contract Workflow ", function(){ 
  it("Testing smart contract safe minting", async () => {
    const instance = await PNDC_ERC721.deployed();
    const instance2 = await TokenFactory.deployed();  

    result = await instance.safeMint(accounts[0],"URI",[[accounts[0],500]]);  
    result2 = await instance.ownerOf(0);
    assert.equal(result.receipt.logs[0].type, "mined", "Failed to mint");   
    assert.equal(result2,accounts[0]);
    
  });  

  it("Testing TokenFactory smart contract initialization ", async () => {
    const instance = await PNDC_ERC721.deployed();
    const instance2 = await TokenFactory.deployed();  

  
    result = await instance2.initialize(instance.address) ;
    assert.equal(result.receipt.logs[0].type, "mined", "Failed to mint");
    
  });  

  it("Testing smart contract sellNFT function ", async () => {
    const instance = await PNDC_ERC721.deployed();
    const instance2 = await TokenFactory.deployed();  

    
    await instance.approve(instance2.address,0);
    result2 = await instance2.sellNFT(instance.address,0,600);
    assert.equal(result2.receipt.logs[0].type, "mined", "Failed to mint");
  });  

  it("Testing smart contract BuyNFT function ", async () => {
    const instance = await PNDC_ERC721.deployed();
    const instance2 = await TokenFactory.deployed();      
    
    result2 = await instance2.BuyNFT(1,{from:accounts[1],value:700});
    rest = await instance.ownerOf(0);
    assert.equal(rest,accounts[1]);
  });    

  it("Testing smart contract SellNFT_byBid", async () => {
    const instance = await PNDC_ERC721.deployed();
    const instance2 = await TokenFactory.deployed();      
    
    await instance.approve(instance2.address,0,{from:accounts[1]});
    await instance2.sellNFT(instance.address,0,600,{from:accounts[1]});
    await instance2.SellNFT_byBid(2,600,{from:accounts[1]});
    result = await instance2._tokenMeta(2)
    assert.equal(result.bidSale, true);
  });  
  
  it("Testing smart contract bidding functionality", async () => {
    const instance = await PNDC_ERC721.deployed();
    const instance2 = await TokenFactory.deployed();      
    
    await instance2.Bid(2,{from:accounts[2],value:1000});
    await instance2.Bid(2,{from:accounts[3],value:1000});
    await instance2.Bid(2,{from:accounts[4],value:1000});
    
    result = await instance2.Bids(2,2)
    assert.equal(result.buyerAddress, accounts[4]);
  });    

  it("Testing the execution of the bid", async () => {
    const instance = await PNDC_ERC721.deployed();
    const instance2 = await TokenFactory.deployed();      
    
    await instance2.executeBidOrder(2,0,{from:accounts[1]});    
    result = await instance.ownerOf(0)
    assert.equal(result , accounts[2]);    
  });    
  
  it("Testing the withdrawal of the bid", async () => {
    const instance = await PNDC_ERC721.deployed();
    const instance2 = await TokenFactory.deployed();      
    
    await instance2.withdrawBidMoney(2,1,{from:accounts[3]});    
    await instance2.withdrawBidMoney(2,2,{from:accounts[4]});   
    result = await web3.eth.getBalance(instance2.address);
    assert.equal( result , 0);
  });    


 })

});
 
});
