var BigNumber = require('big-number');
const TokenERC1155 = artifacts.require("TokenERC1155");
const TokenFactory1155 = artifacts.require("TokenFactory1155");
contract("TokenFactory1155", (accounts) => { 
 describe("Testing Collections Workflow ", function(){ 
   
  it("Testing deployment of collection", async () => {
    const instance = await TokenFactory1155.deployed();   

    result = await instance.deployERC1155("uri","Description Of ERC1155 Collection",[[accounts[3],500]]);  
    assert.equal(result.receipt.logs[0].type, "mined", "Failed to mint");     
    
  });  

  it("Creating new TokenERC1155 instance", async () => {
    const instance = await TokenFactory1155.deployed();   

    collectionMeta = await instance.collections(1);
    //console.log(collectionMeta)
    collectionAddress = collectionMeta[1];

    instance2 = await TokenERC1155.at(collectionAddress);
    result = await instance2.owner();
    assert.equal(result, accounts[0]);     
    
  });  

  
  it("Testing minting inside TokenERC721 contract", async () => {
    const instance = await TokenFactory1155.deployed();   
    collectionMeta = await instance.collections(1);
    collectionAddress = collectionMeta[1];
    instance2 = await TokenERC1155.at(collectionAddress);

    
    result = await instance2.mint(accounts[0],0,10,"uri",[]);
    assert.equal(result.receipt.logs[0].type, "mined", "Failed to mint");     
    
  });  


  it("Testing collection sale", async () => {
    const instance = await TokenFactory1155.deployed();  
    collectionMeta = await instance.collections(1);
    collectionAddress = collectionMeta[1];
    instance2 = await TokenERC1155.at(collectionAddress); 
    
    
    await instance2.setApprovalForAll(instance.address,true);
    result = await instance.sellNFT(collectionAddress,0,500,5);

    assert.equal(result.receipt.logs[0].type, "mined", "Failed to mint");
    
    assert.equal(await instance2.balanceOf(accounts[0], 0), "5");
    assert.equal(await instance2.balanceOf(instance.address, 0), "5");
    
  });  

  it("Testing collections smart contract BuyNFT function ", async () => {
   
    const instance = await TokenFactory1155.deployed();   
    collectionMeta = await instance.collections(1);
    collectionAddress = collectionMeta[1];
    instance2 = await TokenERC1155.at(collectionAddress);  
    
    let _balance1 = await web3.eth.getBalance(accounts[0]);
    let _balance2 = await web3.eth.getBalance(accounts[3]);

    let meta = await instance._tokenMeta(1);
    //console.log(meta)
    assert.equal(meta.status, true);
    
    result2 = await instance.BuyNFT(1, 2,{from:accounts[1],value:1000});

    assert.equal(await instance2.balanceOf(instance.address, 0), "3")
    assert.equal(await instance2.balanceOf(accounts[1], 0), "2")

    let balance1 = await web3.eth.getBalance(accounts[0]);
    let balance2 = await web3.eth.getBalance(accounts[3]);

    assert.equal(BigNumber(balance2).minus(BigNumber(_balance2)) , (1000 * 500) / 10000)
    assert.equal(BigNumber(balance1).minus(BigNumber(_balance1)), (1000 * 9400) / 10000)

    await instance.BuyNFT(1, 3,{from:accounts[1],value:1500});
    meta = await instance._tokenMeta(1);
    assert.equal(meta.status, false);

    // meta = await instance._tokenMeta(1);
    // assert.equal(meta.status, false);
  });    

  it("Testing collections smart contract SellNFT_byBid", async () => {
    const instance = await TokenFactory1155.deployed();   
    collectionMeta = await instance.collections(1);
    collectionAddress = collectionMeta[1];
    instance2 = await TokenERC1155.at(collectionAddress);       
    
    await instance2.setApprovalForAll(instance.address,true,{from:accounts[1]});
    await instance.SellNFT_byBid(collectionAddress,0,500,2,{from:accounts[1]});
    result = await instance._tokenMeta(2)
    assert.equal(result.bidSale, true);
  });  
  
  it("Testing collections smart contract bidding functionality", async () => {
    const instance = await TokenFactory1155.deployed();   
    collectionMeta = await instance.collections(1);
    collectionAddress = collectionMeta[1];
    instance2 = await TokenERC1155.at(collectionAddress);          
    
    await instance.Bid(2,2,{from:accounts[2],value:1000});
    await instance.Bid(2,2,{from:accounts[3],value:1000});
    await instance.Bid(2,2,{from:accounts[4],value:1000});
    
    result = await instance.Bids(2,2)
    assert.equal(result.buyerAddress, accounts[4]);
  });    

  it("Testing the execution of the bid of the collections", async () => {
    const instance = await TokenFactory1155.deployed();   
    collectionMeta = await instance.collections(1);
    collectionAddress = collectionMeta[1];
    instance2 = await TokenERC1155.at(collectionAddress);   
    
    let _balance1 = await web3.eth.getBalance(accounts[3]);
    
    await instance.executeBidOrder(2,0,{from:accounts[1]});    
    
    assert.equal(await instance2.balanceOf(accounts[2], 0), 2);

    let balance1 = await web3.eth.getBalance(accounts[3]);
    assert.equal(BigNumber(balance1).minus(BigNumber(_balance1)), (1000 * 500) / 10000)

    let meta = await instance._tokenMeta(2);
    assert.equal(meta.status, false);
  });    
  
  it("Testing the withdrawal of the bid of the collections", async () => {
    const instance = await TokenFactory1155.deployed();   
    collectionMeta = await instance.collections(1);
    collectionAddress = collectionMeta[1];
    instance2 = await TokenERC1155.at(collectionAddress);        
    
    await instance.withdrawBidMoney(2,1,{from:accounts[3]});    
    await instance.withdrawBidMoney(2,2,{from:accounts[4]});   
    result = await web3.eth.getBalance(instance.address);
    assert.equal( result , 0);
  });   
  
  it("Testing the sale cancelation", async () => {
    const instance = await TokenFactory1155.deployed();   
    collectionMeta = await instance.collections(1);
    collectionAddress = collectionMeta[1];
    instance2 = await TokenERC1155.at(collectionAddress);

    result = await instance2.mint(accounts[0],1,10,"uri",[]);  
    result2 = await instance2.balanceOf(accounts[0],1);
    assert.equal(result.receipt.logs[0].type, "mined", "Failed to mint");   
    assert.equal(result2,10);

    await instance2.setApprovalForAll(instance.address, true);
    await instance.sellNFT(instance2.address, 1, 600, 10);
    
    assert.equal(await instance2.balanceOf(instance.address, 1), 10)
    assert.equal(await instance2.balanceOf(accounts[0], 1), 0)

    await instance.cancelSale(3);
    meta = await instance._tokenMeta(3);
    assert.equal(meta.status, false);
    assert.equal(await instance2.balanceOf(accounts[0], 1), 10)

  });



 })

});
 
