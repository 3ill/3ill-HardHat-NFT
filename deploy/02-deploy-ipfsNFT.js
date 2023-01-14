const { network, ethers } = require("hardhat");
const {storeImages } = require("../utils/uploadToPinata")
const {
  developmentChains,
  networkConfig,
} = require("../helper-hardhat-config");

const imagesFilePath = './../Images/randomNFTS'
const BASE_FEE = "250000000000000000" // 0.25 is this the premium in LINK?
const GAS_PRICE_LINK = 1e9 // link per gas, is this the gas lane? // 0.000000001 LINK per gas

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = network.config.chainId;
  

  let tokenURIS

  if(process.env.UPLOAD_TO_PINANTA == true) {
    tokenURIS = await handleTokenURIS();
  }

  let vrfCoordinatorV2Address, subscriptionId;
  if (developmentChains.includes(network.name)) {
    const vrfCoordinatorV2Mock = await ethers.getContractFactory(
      "VRFCoordinatorV2Mock"
    );
    const VRFCoordinatorV2Mock =   await vrfCoordinatorV2Mock.deploy(BASE_FEE, GAS_PRICE_LINK);

    vrfCoordinatorV2Address = VRFCoordinatorV2Mock.address
    console.log("🚀 ~ file: 02-deploy-ipfsNFT.js:32 ~ module.exports= ~ vrfCoordinatorV2Address", vrfCoordinatorV2Address)
   
    
    const tx = await VRFCoordinatorV2Mock.createSubscription();
    const receipt = await tx.wait(1);
    subscriptionId = receipt.events[0].args.subId;
  } else {
    vrfCoordinatorV2Address = networkConfig[chainId].vrfCoordinatorV2Address;
    subscriptionId = networkConfig[chainId].subscriptionId;
  }

  log("_________________________");
  await storeImages(imagesFilePath);
  
  // const args = [
  //   vrfCoordinatorV2Address,
  //   subscriptionId,
  //   networkConfig[chainId].gasLane,
  //   networkConfig[chainId].callbackGasLimit,
  //   /**SpeciesURI */,
  //   ,
  //   networkConfig[chainId].mintFee,
  // ];
};

const handleTokenURIS = async () => {
  tokenURIS = [];
  return tokenURIS;
}

module.exports.tags = ["all", "ipfs", "main"];
