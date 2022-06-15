const { ethers } = require("hardhat")
require("dotenv").config()
const { CRYPTO_DEVS_NFT_CONTRACT_ADDRESS } = require("../constants")

async function main() {
    const nftContractAddress = CRYPTO_DEVS_NFT_CONTRACT_ADDRESS
    /*
    A ContractFactory in ethers.js is an abstraction used to deploy new smart contracts,
    so cryptoDevsTokenContract here is a factory for instances of our CryptoDevToken contract.
    */
    const cryptoDevsTokenContract = await ethers.getContractFactory(
        "CryptoDevToken"
    )

    //deploy the contract
    const deployedCryptoDevsTokenContract =
        await cryptoDevsTokenContract.deploy(nftContractAddress)

    console.log(
        `Crypto Devs Token Contract Address: ${deployedCryptoDevsTokenContract.address}`
    )
}

main()
    .then(() => process.exit(0))
    .catch((err) => {
        console.log(err)
        process.exit(1)
    })
