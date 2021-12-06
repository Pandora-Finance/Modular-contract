const NFTBid = artifacts.require("NFTBid");

contract("NFTBid", (accounts) => {
  it("Testing smart contract function mintNFT() that mints NFT", async () => {
    const instance = await NFTBid.deployed();

    let result = await instance.mintNFT(
      "https://example.com/token_uri",
      "NFT Name",
      5000000
    );

    assert.equal(result.receipt.logs[0].type, "mined", "Failed to mint");
  });

  it("Testing smart contract function SellNFT_byBid() that enable NFT for sell", async () => {
    const instance = await NFTBid.deployed();

    let result = await instance.SellNFT_byBid(1, 5500000);

    assert.equal(result.receipt.status, true, "Failed to enable NFT for sell");
  });

  it("Testing smart contract function Bid() that enable bidding for NFT to sell", async () => {
    const instance = await NFTBid.deployed();

    let result = await instance.Bid(1, { from: accounts[1], value: 7000000 });
    let result2 = await instance.Bid(1, { from: accounts[2], value: 8000000 });

    assert.equal(result.receipt.status, true, "Failed to place a bid order");
    assert.equal(result2.receipt.status, true, "Failed to place a bid order");
  });

  it("Testing smart contract function executeBidOrder() that enables owner of NFT to execute the bid order", async () => {
    const instance = await NFTBid.deployed();

    let result = await instance.executeBidOrder(1, 0);

    assert.equal(
      result.receipt.logs[1].event,
      "Transfer",
      "NFT Transfer Failed"
    );
  });

  it("Testing smart contract function withdrawBidMoney() that enables bidder withdraw their bid money", async () => {
    const instance = await NFTBid.deployed();

    let result = await instance.withdrawBidMoney(1, 1, { from: accounts[2] });

    assert.equal(result.receipt.status, true, "Failed to withdraw money");
  });

  it("Testing smart contract function SellNFT() that enable direct sell of NFT", async () => {
    const instance = await NFTBid.deployed();

    await instance.mintNFT(
      "https://example.com/token_uri",
      "NFT Info",
      5500000
    );
    let result = await instance.SellNFT(2, 7000000);

    assert.equal(result.receipt.status, true, "Failed to enable Direct sell");
  });

  it("Testing smart contract function BuyNFT() that enable buying of NFT", async () => {
    const instance = await NFTBid.deployed();

    await instance.mintNFT(
      "https://example.com/token_uri",
      "NFT Info",
      5500000
    );
    let result = await instance.BuyNFT(2, {
      from: accounts[1],
      value: 7000000,
    });

    assert.equal(result.receipt.status, true, "Failed to enable Direct buy");
  });

  it("Testing smart contract function batchMint() that mints NFT in batch", async () => {
    const instance = await NFTBid.deployed();

    let result = await instance.batchMint(
      3,
      ["ksd", "sfdsf", "sdfsf"],
      [
        "https://example.com/token_uri",
        "https://example.com/token_uri",
        "https://example.com/token_uri",
      ],
      [5000000, 5500000, 6000000]
    );
    assert.equal(result.receipt.status, true, "Failed to mint");
  });
});
