
const TokenERC721 = artifacts.require("TokenERC721");
const TokenFactory = artifacts.require("TokenFactory");
contract("TokenFactory", (accounts) => { 
 describe("Testing Collections Workflow ", function(){ 
  it("Testing deployment of collection", async () => {
    const instance = await TokenFactory.deployed();   

    result = await instance.deployERC721("nameERC721","SymbolERC721","Description Of ERC721 Collection",[[accounts[0],500]]);  
    assert.equal(result.receipt.logs[0].type, "mined", "Failed to mint");     
    
  });  

  it("Creating new TokenERC721 instance", async () => {
    const instance = await TokenFactory.deployed();   

    collectionMeta = await instance.collections(1);
    collectionAddress = collectionMeta[3];

    instance2 = await TokenERC721.at(collectionAddress);
    result = await instance2.owner();
    assert.equal(result, accounts[0]);     
    
  });  

  
  it("Testing minting inside TokenERC721 contract", async () => {
    const instance = await TokenFactory.deployed();  
    instance2 = await TokenERC721.at(collectionAddress); 
    collectionMeta = await instance.collections(1);
    collectionAddress = collectionMeta[3];

    
    result = await instance2.safeMint(accounts[0],"URI_ERC721",[true,[[accounts[0],600]]]);
    assert.equal(result.receipt.logs[0].type, "mined", "Failed to mint");     
    
  });  


  it("Testing collection sale", async () => {
    const instance = await TokenFactory.deployed();  
    collectionMeta = await instance.collections(1);
    collectionAddress = collectionMeta[3];
    instance2 = await TokenERC721.at(collectionAddress); 
    
    
    await instance2.approve(instance.address,0);
    result = await instance.sellNFT(collectionAddress,0,500);

    assert.equal(result.receipt.logs[0].type, "mined", "Failed to mint");     
    
  });  

  it("Testing collections smart contract BuyNFT function ", async () => {
   
    const instance = await TokenFactory.deployed();   
    collectionMeta = await instance.collections(1);
    collectionAddress = collectionMeta[3];
    instance2 = await TokenERC721.at(collectionAddress);    
    
    result2 = await instance.BuyNFT(1,{from:accounts[1],value:700});
    rest = await instance2.ownerOf(0);
    assert.equal(rest,accounts[1]);
  });    

  it("Testing collections smart contract SellNFT_byBid", async () => {
    const instance = await TokenFactory.deployed();   
    collectionMeta = await instance.collections(1);
    collectionAddress = collectionMeta[3];
    instance2 = await TokenERC721.at(collectionAddress);       
    
    await instance2.approve(instance.address,0,{from:accounts[1]});
    await instance.sellNFT(collectionAddress,0,600,{from:accounts[1]});
    await instance.SellNFT_byBid(2,600,{from:accounts[1]});
    result = await instance._tokenMeta(2)
    assert.equal(result.bidSale, true);
  });  
  
  it("Testing collections smart contract bidding functionality", async () => {
    const instance = await TokenFactory.deployed();   
    collectionMeta = await instance.collections(1);
    collectionAddress = collectionMeta[3];
    instance2 = await TokenERC721.at(collectionAddress);          
    
    await instance.Bid(2,{from:accounts[2],value:1000});
    await instance.Bid(2,{from:accounts[3],value:1000});
    await instance.Bid(2,{from:accounts[4],value:1000});
    
    result = await instance.Bids(2,2)
    assert.equal(result.buyerAddress, accounts[4]);
  });    

  it("Testing the execution of the bid of the collections", async () => {
    const instance = await TokenFactory.deployed();   
    collectionMeta = await instance.collections(1);
    collectionAddress = collectionMeta[3];
    instance2 = await TokenERC721.at(collectionAddress);      
    
    await instance.executeBidOrder(2,0,{from:accounts[1]});    
    result = await instance2.ownerOf(0)
    assert.equal(result , accounts[2]);    
  });    
  
  it("Testing the withdrawal of the bid of the collections", async () => {
    const instance = await TokenFactory.deployed();   
    collectionMeta = await instance.collections(1);
    collectionAddress = collectionMeta[3];
    instance2 = await TokenERC721.at(collectionAddress);        
    
    await instance.withdrawBidMoney(2,1,{from:accounts[3]});    
    await instance.withdrawBidMoney(2,2,{from:accounts[4]});   
    result = await web3.eth.getBalance(instance.address);
    assert.equal( result , 0);
  });    



 })

});
 
