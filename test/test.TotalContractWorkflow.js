var BigNumber = require('big-number');
const PNDC_ERC721 = artifacts.require("PNDC_ERC721");
const TokenFactory = artifacts.require("TokenFactory");
contract("PNDC_ERC721", (accounts) => {
  contract("TokenFactory", (accounts) => { 
 describe("Testing Contract Workflow ", function(){ 
  it("Testing smart contract safe minting", async () => {
    const instance = await PNDC_ERC721.deployed();
    const instance2 = await TokenFactory.deployed();  

    result = await instance.safeMint(accounts[0],"URI",[[accounts[3],500]]);  
    result2 = await instance.ownerOf(0);
    assert.equal(result.receipt.logs[0].type, "mined", "Failed to mint");   
    assert.equal(result2,accounts[0]);
    
  });  

  it("Testing TokenFactory smart contract initialization ", async () => {
    const instance = await PNDC_ERC721.deployed();
    const instance2 = await TokenFactory.deployed();  

  
    //result = await instance2.initialize(instance.address) ;
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
    
    let _balance1 = await web3.eth.getBalance(accounts[0]);
    let _balance2 = await web3.eth.getBalance(accounts[3]);

    let meta = await instance2._tokenMeta(1);
    assert.equal(meta.status, true);
    
    result2 = await instance2.BuyNFT(1,{from:accounts[1],value:700});
    rest = await instance.ownerOf(0);
    assert.equal(rest,accounts[1]);

    let balance1 = await web3.eth.getBalance(accounts[0]);
    let balance2 = await web3.eth.getBalance(accounts[3]);

    assert.equal(BigNumber(balance2).minus(BigNumber(_balance2)) , (700 * 500) / 10000)
    assert.equal(BigNumber(balance1).minus(BigNumber(_balance1)), (700 * 9400) / 10000)

    meta = await instance2._tokenMeta(1);
    assert.equal(meta.status, false);
  });    

  it("Testing smart contract SellNFT_byBid", async () => {
    const instance = await PNDC_ERC721.deployed();
    const instance2 = await TokenFactory.deployed();      
    
    await instance.approve(instance2.address,0,{from:accounts[1]});
    await instance2.SellNFT_byBid(instance.address,0,600,300,{from:accounts[1]});
    result = await instance2._tokenMeta(2)
    assert.equal(result.bidSale, true);
  });  
  
  it("Testing smart contract bidding functionality", async () => {
    const instance = await PNDC_ERC721.deployed();
    const instance2 = await TokenFactory.deployed();      
    
    await instance2.Bid(2,{from:accounts[2],value:1000});
    await instance2.Bid(2,{from:accounts[3],value:1100});
    await instance2.Bid(2,{from:accounts[4],value:1200});
    
    result = await instance2.Bids(2,2)
    assert.equal(result.buyerAddress, accounts[4]);
  });    

  it("Testing the execution of the bid", async () => {
    const instance = await PNDC_ERC721.deployed();
    const instance2 = await TokenFactory.deployed(); 
    
    let _balance1 = await web3.eth.getBalance(accounts[3]);
    
    await instance2.executeBidOrder(2,0,{from:accounts[1]});    
    result = await instance.ownerOf(0)
    assert.equal(result , accounts[2]);  
    
    let balance1 = await web3.eth.getBalance(accounts[3]);
    assert.equal(BigNumber(balance1).minus(BigNumber(_balance1)), (1000 * 500) / 10000)
  });    
  
  it("Testing the withdrawal of the bid", async () => {
    const instance = await PNDC_ERC721.deployed();
    const instance2 = await TokenFactory.deployed();      
    
    await instance2.withdrawBidMoney(2,1,{from:accounts[3]});    
    await instance2.withdrawBidMoney(2,2,{from:accounts[4]});   
    result = await web3.eth.getBalance(instance2.address);
    assert.equal( result , 0);
  });
  
  it("Testing the sale cancelation", async () => {
    const instance = await PNDC_ERC721.deployed();
    const instance2 = await TokenFactory.deployed(); 

    result = await instance.safeMint(accounts[0],"URI",[[accounts[0],500]]);  
    result2 = await instance.ownerOf(1);
    assert.equal(result.receipt.logs[0].type, "mined", "Failed to mint");   
    assert.equal(result2,accounts[0]);

    await instance.approve(instance2.address, 1);
    await instance2.sellNFT(instance.address, 1, 600);
    assert.equal(await instance.ownerOf(1), instance2.address);
    
    await instance2.cancelSale(3);
    assert.equal(await instance.ownerOf(1), accounts[0]);

    let res = await instance2._tokenMeta(3);
    assert.equal(res.status, false);

    await instance.approve(instance2.address, 1);
    await instance2.SellNFT_byBid(instance.address, 1, 600, 300);
    assert.equal(await instance.ownerOf(1), instance2.address);
    
    await instance2.cancelSale(4);
    assert.equal(await instance.ownerOf(1), accounts[0]);

    res = await instance2._tokenMeta(4);
    assert.equal(res.status, false);

  });

  it("Testing the burn function", async () => {
    const instance = await PNDC_ERC721.deployed();

    result = await instance.safeMint(accounts[0],"URI",[[accounts[0],500]]);  
    result2 = await instance.ownerOf(2);
    assert.equal(result.receipt.logs[0].type, "mined", "Failed to mint");   
    assert.equal(result2,accounts[0]);

    result3 = await instance.burn(2);
    assert.equal(result3.receipt.logs[0].type, "mined", "Failed to mint");

  });


 })

});
 
});
