const { ethers } = require("hardhat")

async function main() {
    const [deployer] = await ethers.getSigners()

    console.log("Deploying contracts with the account:", deployer.address)
    console.log("Account balance:", (await deployer.getBalance()).toString())

    // Get the ContractFactories and Signers here.
    const NFT = await ethers.getContractFactory("NFT")
    const Marketplace = await ethers.getContractFactory("Marketplace")

    // deploy contracts
    const nft = await NFT.deploy()
    const marketplace = await Marketplace.deploy(1)
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
