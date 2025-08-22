// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {NFT} from "../src/NFT.sol";

contract NTFTest is Test {
    NFT public nft;
    address user1 = address(0x11111);
    address user2 = address(0x22222);

    function setUp() public {
        nft = new NFT("web3compass NFT", "W3CP");
    }

    function testMintNewToken() public {
        nft.mintNewToken(user1, "ipfs://e33f3f3f3f3/1");
        nft.mintNewToken(user2, "ipfs://e33f3f3f3f3/2");
        console.log(nft.tokenURI(0));
        console.log(nft.tokenURI(1));
    }
}
