require("@nomiclabs/hardhat-waffle")
require("dotenv").config({ path: ".env" })

const RINKEBY_API_URL = process.env.RINKEBY_URL
const PRIVATE_KEY = process.env.PRIVATE_KEY

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
    networks: {
        rinkeby: {
            chainId: 4,
            url: RINKEBY_API_URL,
            accounts: PRIVATE_KEY ? [PRIVATE_KEY] : [""],
        },
    },
    solidity: "0.8.10",
}
