// SPDX-License-Identifier: MIT

/* 
    This was deployed on Anvil with:

    forge create src/NFT.sol:NFT 
        --rpc-url http://localhost:8545 
        --private-key <private-key> 
        --broadcast 
        --constructor-args "web3compass NFT" "W3CP"

/* 
    A new token was minted with:

    cast send <deployed-address>
        "mintNewToken(address, string)" 
        0x0000000000000000000000000000000000011111 "ipfs://e33f3f3f3f3/1" 
        --private-key <private-key>
*/

/*
    The tokenURI (metadata location) was retrieved with:

    cast call <deployed-address> 
        "tokenURI(uint256)" 0 
        --account <account>

*/

/*
    The tokenURI hex response was decoded with:

    cast to-ascii <hex-string returned>

*/

/*
    ownerOf was called with:

    cast call <deployed-address> 
        "ownerOf(uint256)" 0 
        --account <account>
*/

pragma solidity ^0.8.20;

import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract NFT is ERC721URIStorage, Ownable {
    uint256 private _nextTokenId;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) Ownable(msg.sender) {}

    function mintNewToken(address destination, string memory uri) external onlyOwner {
        uint256 tokenId = _nextTokenId;
        _safeMint(destination, tokenId);
        _setTokenURI(tokenId, uri);
        _nextTokenId++;
    }
}
