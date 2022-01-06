var BigNumber = require('big-number');
const PNDC_ERC1155 = artifacts.require("PNDC_ERC1155");
const TokenFactory1155 = artifacts.require("TokenFactory1155");
contract("PNDC_ERC1155", (accounts) => {
  contract("TokenFactory1155", (accounts) => { 
 describe("Testing Contract Workflow ", function(){ 
  it("Testing smart contract safe minting", async () => {
    const instance2 = await PNDC_ERC1155.deployed();
    const instance = await TokenFactory1155.deployed();  

    result = await instance2.mint(accounts[0],10,[],[[accounts[3],500]]);  
    result2 = await instance2.balanceOf(accounts[0],0);
    assert.equal(result.receipt.logs[0].type, "mined", "Failed to mint");   
    assert.equal(result2,10);
    
  });  

  it("Testing TokenFactory smart contract initialization ", async () => {
    const instance2 = await PNDC_ERC1155.deployed();
    const instance = await TokenFactory1155.deployed();  

  
    //result = await instance2.initialize(instance.address) ;
    assert.equal(result.receipt.logs[0].type, "mined", "Failed to mint");
    
  });  

  it("Testing smart contract sellNFT function ", async () => {
    const instance2 = await PNDC_ERC1155.deployed();
    const instance = await TokenFactory1155.deployed();  

    
    await instance2.setApprovalForAll(instance.address,true);
    result = await instance.sellNFT(instance2.address,0,500,5);

    assert.equal(result.receipt.logs[0].type, "mined", "Failed to mint");
    
    assert.equal(await instance2.balanceOf(accounts[0], 0), "5");
    assert.equal(await instance2.balanceOf(instance.address, 0), "5");
  });  

  it("Testing smart contract BuyNFT function ", async () => {
    const instance2 = await PNDC_ERC1155.deployed();
    const instance = await TokenFactory1155.deployed();
    
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
    assert.equal(BigNumber(balance1).minus(BigNumber(_balance1)), (1000 * 9500) / 10000)

    // meta = await instance._tokenMeta(1);
    // assert.equal(meta.status, false);
  });    

  it("Testing smart contract SellNFT_byBid", async () => {
    const instance2 = await PNDC_ERC1155.deployed();
    const instance = await TokenFactory1155.deployed();      
    
    await instance2.setApprovalForAll(instance.address,true,{from:accounts[1]});
    await instance.SellNFT_byBid(instance2.address,0,500,2,{from:accounts[1]});
    result = await instance._tokenMeta(2)
    assert.equal(result.bidSale, true);
  });  
  
  it("Testing smart contract bidding functionality", async () => {
    const instance2 = await PNDC_ERC1155.deployed();
    const instance = await TokenFactory1155.deployed();      
    
    await instance.Bid(2,2,{from:accounts[2],value:1000});
    await instance.Bid(2,2,{from:accounts[3],value:1000});
    await instance.Bid(2,2,{from:accounts[4],value:1000});
    
    result = await instance.Bids(2,2)
    assert.equal(result.buyerAddress, accounts[4]);
  });    

  it("Testing the execution of the bid", async () => {
    const instance2 = await PNDC_ERC1155.deployed();
    const instance = await TokenFactory1155.deployed(); 
    
    let _balance1 = await web3.eth.getBalance(accounts[3]);
    
    await instance.executeBidOrder(2,0,{from:accounts[1]});    
    
    assert.equal(await instance2.balanceOf(accounts[2], 0), 2);

    let balance1 = await web3.eth.getBalance(accounts[3]);
    assert.equal(BigNumber(balance1).minus(BigNumber(_balance1)), (1000 * 500) / 10000)
  });    
  
  it("Testing the withdrawal of the bid", async () => {
    const instance2 = await PNDC_ERC1155.deployed();
    const instance = await TokenFactory1155.deployed();      
    
    await instance.withdrawBidMoney(2,1,{from:accounts[3]});    
    await instance.withdrawBidMoney(2,2,{from:accounts[4]});   
    result = await web3.eth.getBalance(instance.address);
    assert.equal( result , 0);
  });
  
  it("Testing the sale cancelation", async () => {
    const instance2 = await PNDC_ERC1155.deployed();
    const instance = await TokenFactory1155.deployed(); 

    result = await instance2.mint(accounts[0],10,[],[[accounts[3],500]]);  
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
 
});
