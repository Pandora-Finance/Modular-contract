var BigNumber = require("big-number");
const PNDC_ERC721 = artifacts.require("PNDC_ERC721");
const TokenFactory = artifacts.require("TokenFactory");
const ProxyFactory = artifacts.require("ProxyFactory");
const Web3 = require("web3");
const web3 = new Web3("http://127.0.0.1:9545")
contract("PNDC_ERC721", (accounts) => {
  contract("ProxyFactory", (accounts) => {
    describe("Testing Contract Workflow ", function () {
      it("Testing TokenFactoryClone smart contract initialization ", async () => {
        const instance = await PNDC_ERC721.deployed();
        const clone = await ProxyFactory.deployed();

        let data = await web3.eth.abi.encodeFunctionCall(
          {
            name: 'initialize',
            type: 'function',
            inputs: [
              {
                type: 'address',
                name: '_address'
              },
              {
                type: 'address',
                name: '_feeAddress'
              }
            ]
          },
          [instance.address, accounts[0]]
        );

        let version = await clone.currentVersion("marketplace");
        assert.equal(version.words[0], 1);

        result = await clone.cloneContract("marketplace", data, accounts[0]);
        //console.log(result);

        result2 = await clone.returnProxies(accounts[0]);

        assert.equal(await result.logs[0].address, result2[0][2]);

        let meta = await clone.proxyMetadata(result2[0][2]);
        assert.equal(meta.contractVersion, 1);
        assert.equal(meta.contractType, "marketplace");
        assert.equal(meta.proxyAddress, result2[0][2])

        const instance2 = await TokenFactory.at(result2[0][2]);
        assert.equal(await instance2.owner(), accounts[0]);
      });

      it("Testing smart contract safe minting", async () => {
        const instance = await PNDC_ERC721.deployed();
        const clone = await ProxyFactory.deployed();
        cloneAddress = await clone.returnProxies(accounts[0]);
        const instance2 = await TokenFactory.at(cloneAddress[0][2]);

        result = await instance.safeMint(accounts[0], "URI", [
          [accounts[3], 500],
        ]);
        result2 = await instance.ownerOf(0);
        assert.equal(result.receipt.status, true);
        assert.equal(result2, accounts[0]);
      });

      it("Testing smart contract sellNFT function ", async () => {
        const instance = await PNDC_ERC721.deployed();
        const clone = await ProxyFactory.deployed();
        cloneAddress = await clone.returnProxies(accounts[0]);
        const instance2 = await TokenFactory.at(cloneAddress[0][2]);

        await instance.approve(instance2.address, 0);
        result2 = await instance2.sellNFT(instance.address, 0, 600);
        assert.equal(result2.receipt.status, true);
      });

      it("Testing smart contract BuyNFT function ", async () => {
        const instance = await PNDC_ERC721.deployed();
        const clone = await ProxyFactory.deployed();
        cloneAddress = await clone.returnProxies(accounts[0]);
        const instance2 = await TokenFactory.at(cloneAddress[0][2]);

        let _balance1 = await web3.eth.getBalance(accounts[0]);
        let _balance2 = await web3.eth.getBalance(accounts[3]);

        let meta = await instance2._tokenMeta(1);
        assert.equal(meta.status, true);

        result2 = await instance2.BuyNFT(1, { from: accounts[1], value: 700 });
        rest = await instance.ownerOf(0);
        assert.equal(rest, accounts[1]);

        let balance1 = await web3.eth.getBalance(accounts[0]);
        let balance2 = await web3.eth.getBalance(accounts[3]);

        assert.equal(
          BigNumber(balance2).minus(BigNumber(_balance2)),
          (700 * 500) / 10000
        );
        assert.equal(
          BigNumber(balance1).minus(BigNumber(_balance1)),
          (700 * 9500) / 10000
        );

        meta = await instance2._tokenMeta(1);
        assert.equal(meta.status, false);
      });

      it("Testing smart contract SellNFT_byBid", async () => {
        const instance = await PNDC_ERC721.deployed();
        const clone = await ProxyFactory.deployed();
        cloneAddress = await clone.returnProxies(accounts[0]);
        const instance2 = await TokenFactory.at(cloneAddress[0][2]);

        await instance.approve(instance2.address, 0, { from: accounts[1] });
        await instance2.SellNFT_byBid(instance.address, 0, 600, 300, {
          from: accounts[1],
        });
        result = await instance2._tokenMeta(2);
        assert.equal(result.bidSale, true);
      });

      it("Testing smart contract bidding functionality", async () => {
        const instance = await PNDC_ERC721.deployed();
        const clone = await ProxyFactory.deployed();
        cloneAddress = await clone.returnProxies(accounts[0]);
        const instance2 = await TokenFactory.at(cloneAddress[0][2]);

        await instance2.Bid(2, { from: accounts[2], value: 1000 });
        await instance2.Bid(2, { from: accounts[3], value: 1100 });
        await instance2.Bid(2, { from: accounts[4], value: 1200 });

        result = await instance2.Bids(2, 2);
        assert.equal(result.buyerAddress, accounts[4]);
      });

      it("Testing the execution of the bid", async () => {
        const instance = await PNDC_ERC721.deployed();
        const clone = await ProxyFactory.deployed();
        cloneAddress = await clone.returnProxies(accounts[0]);
        const instance2 = await TokenFactory.at(cloneAddress[0][2]);

        let _balance1 = await web3.eth.getBalance(accounts[3]);

        await instance2.executeBidOrder(2, 0, { from: accounts[1] });
        result = await instance.ownerOf(0);
        assert.equal(result, accounts[2]);

        let balance1 = await web3.eth.getBalance(accounts[3]);
        assert.equal(
          BigNumber(balance1).minus(BigNumber(_balance1)),
          (1000 * 500) / 10000
        );
      });

      it("Testing the withdrawal of the bid", async () => {
        const instance = await PNDC_ERC721.deployed();
        const clone = await ProxyFactory.deployed();
        cloneAddress = await clone.returnProxies(accounts[0]);
        const instance2 = await TokenFactory.at(cloneAddress[0][2]);

        await instance2.withdrawBidMoney(2, 1, { from: accounts[3] });
        await instance2.withdrawBidMoney(2, 2, { from: accounts[4] });
        result = await web3.eth.getBalance(instance2.address);
        assert.equal(result, 0);
      });

      it("Testing the sale cancelation", async () => {
        const instance = await PNDC_ERC721.deployed();
        const clone = await ProxyFactory.deployed();
        cloneAddress = await clone.returnProxies(accounts[0]);
        const instance2 = await TokenFactory.at(cloneAddress[0][2]);

        result = await instance.safeMint(accounts[0], "URI", [
          [accounts[0], 500],
        ]);
        result2 = await instance.ownerOf(1);
        assert.equal(result.receipt.status, true);
        assert.equal(result2, accounts[0]);

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

        result = await instance.safeMint(accounts[0], "URI", [
          [accounts[0], 500],
        ]);
        result2 = await instance.ownerOf(2);
        assert.equal(result.receipt.status, true);
        assert.equal(result2, accounts[0]);

        result3 = await instance.burn(2);
        assert.equal(result3.receipt.status, true);
      });

      it("Testing the implementation updating", async () => {
        const clone = await ProxyFactory.deployed();
        cloneAddress = await clone.returnProxies(accounts[0]);
        const instance2 = await TokenFactory.at(cloneAddress[0][2]);

        let version = await clone.currentVersion("marketplace");

        const oldImplementation = await clone.implementation("marketplace", version);
        assert.equal(version, 1);

        //fails when address = address(0)
        result = await clone.updateImplementation("marketplace", accounts[3]);

        version = await clone.currentVersion("marketplace");
        assert.equal(version, 2);

        assert.equal(accounts[3], await clone.implementation("marketplace", version));
      });
    });
  });
});
