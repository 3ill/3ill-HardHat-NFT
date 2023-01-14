const {expect} = require("chai");
const { ethers } = require("hardhat");

describe("BasicNFT", () => {
  let user
  let basicNFT;
  let TokenName = "Thrill";
  let TokenSymbol = '3ILL'
  beforeEach( async() => {
    user = await ethers.getSigner();
    const BasicNFT = await ethers.getContractFactory("BasicNFT");
    basicNFT = await BasicNFT.deploy();
  }) 


  it("Returns an address", async () => {
    const address = await  basicNFT.address;
    expect(address).to.equal(await basicNFT.address)
  })

  it("mints an NFT", async () => {
   const mintNFt = await basicNFT.mintNFT();
   await mintNFt.wait(1);
   const tokenCount = await basicNFT.getTokenCounter();
   expect(tokenCount).to.equal(1);
  })

  it("Returns The TokenURI", async () => {
    const token =  await basicNFT.tokenURI(1);
    const GetTokenURI = await basicNFT.getTokenURI();
    expect(token).to.equal(GetTokenURI);
  })
})
