var BigNumber = require('big-number');
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
    collectionAddress = collectionMeta[2];

    instance2 = await TokenERC721.at(collectionAddress);
    result = await instance2.owner();
    assert.equal(result, accounts[0]);     
    
  });  

  
  it("Testing minting inside TokenERC721 contract", async () => {
    const instance = await TokenFactory.deployed();  
    instance2 = await TokenERC721.at(collectionAddress); 
    collectionMeta = await instance.collections(1);
    collectionAddress = collectionMeta[2];

    
    result = await instance2.safeMint(accounts[0],"URI_ERC721",[true,[[accounts[3],600]]]);
    assert.equal(result.receipt.logs[0].type, "mined", "Failed to mint");     
    
  });  


  it("Testing collection sale", async () => {
    const instance = await TokenFactory.deployed();  
    collectionMeta = await instance.collections(1);
    collectionAddress = collectionMeta[2];
    instance2 = await TokenERC721.at(collectionAddress); 
    
    
    await instance2.approve(instance.address,0);
    result = await instance.sellNFT(collectionAddress,0,500);

    assert.equal(result.receipt.logs[0].type, "mined", "Failed to mint");     
    
  });  

  it("Testing collections smart contract BuyNFT function ", async () => {
   
    const instance = await TokenFactory.deployed();   
    collectionMeta = await instance.collections(1);
    collectionAddress = collectionMeta[2];
    instance2 = await TokenERC721.at(collectionAddress);  
    
    let _balance1 = await web3.eth.getBalance(accounts[0]);
    let _balance2 = await web3.eth.getBalance(accounts[3]);

    let meta = await instance._tokenMeta(1);
    assert.equal(meta.status, true);
    
    result2 = await instance.BuyNFT(1,{from:accounts[1],value:700});
    rest = await instance2.ownerOf(0);
    assert.equal(rest,accounts[1]);

    let balance1 = await web3.eth.getBalance(accounts[0]);
    let balance2 = await web3.eth.getBalance(accounts[3]);

    assert.equal(BigNumber(balance2).minus(BigNumber(_balance2)) , (700 * 600) / 10000)
    assert.equal(BigNumber(balance1).minus(BigNumber(_balance1)), (700 * 9300) / 10000)

    meta = await instance._tokenMeta(1);
    assert.equal(meta.status, false);
  });    

  it("Testing collections smart contract SellNFT_byBid", async () => {
    const instance = await TokenFactory.deployed();   
    collectionMeta = await instance.collections(1);
    collectionAddress = collectionMeta[2];
    instance2 = await TokenERC721.at(collectionAddress);       
    
    await instance2.approve(instance.address,0,{from:accounts[1]});
    await instance.SellNFT_byBid(collectionAddress,0,600,300,{from:accounts[1]});
    result = await instance._tokenMeta(2)
    assert.equal(result.bidSale, true);
  });  
  
  it("Testing collections smart contract bidding functionality", async () => {
    const instance = await TokenFactory.deployed();   
    collectionMeta = await instance.collections(1);
    collectionAddress = collectionMeta[2];
    instance2 = await TokenERC721.at(collectionAddress);          
    
    await instance.Bid(2,{from:accounts[2],value:1000});
    await instance.Bid(2,{from:accounts[3],value:1100});
    await instance.Bid(2,{from:accounts[4],value:1200});
    await instance.Bid(2,{from:accounts[5],value:1300});

    //await instance.withdrawBidMoney(2,3,{from:accounts[5]})
    
    result = await instance.Bids(2,2)
    assert.equal(result.buyerAddress, accounts[4]);
  });    

  it("Testing the execution of the bid of the collections", async () => {
    const instance = await TokenFactory.deployed();   
    collectionMeta = await instance.collections(1);
    collectionAddress = collectionMeta[2];
    instance2 = await TokenERC721.at(collectionAddress);   
    
    let _balance1 = await web3.eth.getBalance(accounts[3]);
    
    await instance.executeBidOrder(2,0,{from:accounts[1]});    
    result = await instance2.ownerOf(0)
    assert.equal(result , accounts[2]);    

    let balance1 = await web3.eth.getBalance(accounts[3]);
    assert.equal(BigNumber(balance1).minus(BigNumber(_balance1)), (1000 * 600) / 10000)
  });    
  
  it("Testing the withdrawal of the bid of the collections", async () => {
    const instance = await TokenFactory.deployed();   
    collectionMeta = await instance.collections(1);
    collectionAddress = collectionMeta[2];
    instance2 = await TokenERC721.at(collectionAddress);        
    
    await instance.withdrawBidMoney(2,1,{from:accounts[3]});    
    await instance.withdrawBidMoney(2,2,{from:accounts[4]});
    await instance.withdrawBidMoney(2,3,{from:accounts[5]})   
    result = await web3.eth.getBalance(instance.address);
    assert.equal( result , 0);
  });   
  
  it("Testing the sale cancelation", async () => {
    const instance = await TokenFactory.deployed();   
    collectionMeta = await instance.collections(1);
    collectionAddress = collectionMeta[2];
    instance2 = await TokenERC721.at(collectionAddress);

    result = await instance2.safeMint(accounts[0],"URI",[true,[[accounts[0],600]]]);  
    result2 = await instance2.ownerOf(1);
    assert.equal(result.receipt.logs[0].type, "mined", "Failed to mint");   
    assert.equal(result2,accounts[0]);

    await instance2.approve(instance.address, 1);
    await instance.sellNFT(instance2.address, 1, 600);
    assert.equal(await instance2.ownerOf(1), instance.address);
    
    await instance.cancelSale(3);
    assert.equal(await instance2.ownerOf(1), accounts[0]);

    let res = await instance._tokenMeta(3);
    assert.equal(res.status, false);

    await instance2.approve(instance.address, 1);
    await instance.SellNFT_byBid(instance2.address, 1, 600, 300);
    assert.equal(await instance2.ownerOf(1), instance.address);
    
    await instance.cancelSale(4);
    assert.equal(await instance2.ownerOf(1), accounts[0]);

    res = await instance._tokenMeta(4);
    assert.equal(res.status, false);

  });

  it("Testing the burn function", async () => {
    const instance = await TokenFactory.deployed();   
    collectionMeta = await instance.collections(1);
    collectionAddress = collectionMeta[2];
    instance2 = await TokenERC721.at(collectionAddress);

    result = await instance2.safeMint(accounts[0],"URI",[true,[[accounts[0],600]]]);  
    result2 = await instance2.ownerOf(2);
    assert.equal(result.receipt.logs[0].type, "mined", "Failed to mint");   
    assert.equal(result2,accounts[0]);

    result3 = await instance2.burn(2);
    assert.equal(result3.receipt.logs[0].type, "mined", "Failed to mint");

  });



 })

});
 
