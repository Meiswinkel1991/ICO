// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ICryptoDevs.sol";

error CryptoDevToken__NotEnoughEther();
error CryptoDevToken__ExceedsTotalAvailableSupply();
error CryptoDevToken__DontOwnCryptoNFT();
error CryptoDevToken__AllTokensClaimed();
error CryptoDevToken__SendEtherFailed();

contract CryptoDevToken is ERC20, Ownable {
    //Price of one Crypto Dev token
    uint256 public constant tokenPrice = 0.001 ether;

    // Each NFT would give the user 10 tokens
    // It needs to be represented as 10 * (10 ** 18) as ERC20 tokens are represented by the smallest denomination possible for the token
    // By default, ERC20 tokens have the smallest denomination of 10^(-18). This means, having a balance of (1)
    // is actually equal to (10 ^ -18) tokens.
    // Owning 1 full token is equivalent to owning (10^18) tokens when you account for the decimal places.
    // More information on this can be found in the Freshman Track Cryptocurrency tutorial.
    uint256 public constant tokensPerNFT = 10 * 10**18;
    //the max total supply is 10000 for Crypto Dev Tokens
    uint256 public constant maxTotalSupply = 10000 * 10**18;
    //CryptoDevsNFT contract instance
    ICryptoDevs CrpytoDevsNFT;
    //Mapping to keep track of which tokenIds have been claimed
    mapping(uint256 => bool) public tokenIdsClaimed;

    constructor(address _cryptoDevsContract) ERC20("Crypto Dev Token", "CD") {
        CrpytoDevsNFT = ICryptoDevs(_cryptoDevsContract);
    }

    /**
     * @dev Mints `amount` number of CryptoDevTokens
     * Requirements:
     * - `msg.value` should be equal or greater than the tokenPrice * amount
     */
    function mint(uint256 amount) public payable {
        // the value of ether that should be equal or greater than tokenPrice * amount
        uint256 _requiredAmount = tokenPrice * amount;
        if (_requiredAmount > msg.value) {
            revert CryptoDevToken__NotEnoughEther();
        }

        // total tokens + amoun <= 10000, otherwise revert the transaction
        uint256 amountWithDecimals = amount * 10**18;
        if ((totalSupply() + amountWithDecimals) > maxTotalSupply) {
            revert CryptoDevToken__ExceedsTotalAvailableSupply();
        }

        //call the internal function from Openzeppelin's ERC20 contract
        _mint(msg.sender, amountWithDecimals);
    }

    /**
     * @dev Mints tokens based on the number of NFT's held by the sender
     * Requirements:
     * balance of Crypto Dev NFT's owned by the sender should be greater than 0
     * Tokens should have not been claimed for all the NFTs owned by the sender
     */
    function claim() public {
        //Get the number of CryptoDev NFT's held by given sender address
        uint256 balance = CrpytoDevsNFT.balanceOf(msg.sender);
        //If the balance is zero, revert transaction
        if (balance <= 0) {
            revert CryptoDevToken__DontOwnCryptoNFT();
        }
        //amount keeps track of number of unclaimed tokenIds
        uint256 amount = 0;
        //loop over the balance and get token ID owned by 'sender' at the given 'index' of its token list
        for (uint256 i = 0; i < balance; i++) {
            uint256 tokenId = CrpytoDevsNFT.tokenOfOwnerByIndex(msg.sender, i);
            // if the tokenId has not been claimed, increase the amount
            if (!tokenIdsClaimed[tokenId]) {
                amount += 1;
                tokenIdsClaimed[tokenId] = true;
            }
        }
        // If all the token Ids have been claimed, revert the transaction
        if (amount <= 0) {
            revert CryptoDevToken__AllTokensClaimed();
        }
        // call the internal function from Openzeppelin's ERC20 contract
        // Mint (amount * 10) tokens for each NFT
        _mint(msg.sender, amount * tokensPerNFT);
    }

    /**
     * @dev withdraws all ETH and tokens sent to the contract
     * Requirements:
     * wallet connected must be owner's address
     */
    function withdraw() public onlyOwner {
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) = _owner.call{value: amount}("");
        if (!sent) {
            revert CryptoDevToken__SendEtherFailed();
        }
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}
