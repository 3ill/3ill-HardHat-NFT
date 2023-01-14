const pinataSDK = require("@pinata/sdk");
const path = require("path");
const fs = require("fs");

const storeImages = async (imagesFilePath) => {
  const fullImagesPath = path.resolve(imagesFilePath);
  console.log("🚀 ~ file: uploadToPinata.js:7 ~ storeImages ~ fullImagesPath", fullImagesPath)
  const check = fs.accessSync(fullImagesPath)
  console.log(check)
}

module.exports = { storeImages }