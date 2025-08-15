// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/MockERC20.sol";
import "../src/TokenSwap.sol";

contract TokenSwapTest is Test {
    MockERC20 private tokenA;
    MockERC20 private tokenB;
    TokenSwap private tokenSwap;
    uint256 initialSupply;

    function setUp() public {
        // Deploy mock tokens
        tokenA = new MockERC20("TokenA", "TKA", 2 ether);
        tokenB = new MockERC20("TokenB", "TKB", 2 ether);

        // Deploy swap contract and give it liquidity
        tokenSwap = new TokenSwap(address(tokenA), address(tokenB));
        tokenA.transfer(address(tokenSwap), 1 ether);
        tokenB.transfer(address(tokenSwap), 1 ether);
    }

    // Invariant rule 1a: conservation of supply of token A
    function invariant_supplyTokenA() public view {
        assertEq(tokenA.totalSupply(), 2 ether);
    }

    // Invariant rule 1b: conservation of supply of token B
    function invariant_supplyTokenB() public view {
        assertEq(tokenB.totalSupply(), 2 ether);
    }

    // Invariant rule 2: no negative balances
    function invariant_noNegativeBalances() public view {
        assertEq(tokenA.balanceOf(address(this)) < 0, false);
        assertEq(tokenB.balanceOf(address(this)) < 0, false);
        assertEq(tokenA.balanceOf(address(tokenSwap)) < 0, false);
        assertEq(tokenB.balanceOf(address(tokenSwap)) < 0, false);
    }

    // Invariant rule 3: 1:1 swap guarantee
    function invariant_swapGuarantee() public view {
        // Not possible in the way the test is designed, the fuzzer will break it
        assertEq(tokenA.balanceOf(address(tokenSwap)) + tokenB.balanceOf(address(tokenSwap)), 2 ether);
    }

    // Test the swap functionality simulating this contract as the user
    // and the swap contract as the recipient of tokenA and sender of tokenB.
    function test_SwapAtoB() public {
        // Amount is hardcoded in a regular test
        uint256 testAmount = 10 wei;

        // Our current balances of A and B
        uint256 ourBalanceOfABefore = tokenA.balanceOf(address(this));
        uint256 ourBalanceOfBBefore = tokenB.balanceOf(address(this));

        // Contract's current balance of A and B
        uint256 contractsBalanceOfABefore = tokenA.balanceOf(address(tokenSwap));
        uint256 contractsBalanceOfBBefore = tokenB.balanceOf(address(tokenSwap));

        // Give approval to the swap contract from my address (my address is the default sender)
        tokenA.approve(address(tokenSwap), testAmount);

        // Perform the swap
        tokenSwap.swapAtoB(testAmount);

        // Post checks
        assertEq(tokenA.balanceOf(address(this)), ourBalanceOfABefore - testAmount);
        assertEq(tokenB.balanceOf(address(this)), ourBalanceOfBBefore + testAmount);
        assertEq(tokenA.balanceOf(address(tokenSwap)), contractsBalanceOfABefore + testAmount);
        assertEq(tokenB.balanceOf(address(tokenSwap)), contractsBalanceOfBBefore - testAmount);
    }

    function test_FuzzSwapAtoB(uint256 testAmount) public {
        // We will provide only values higher than zero and within the balance of the contract
        vm.assume(testAmount > 0);
        vm.assume(testAmount <= tokenB.balanceOf(address(tokenSwap)));

        // Our current balances of A and B
        uint256 ourBalanceOfABefore = tokenA.balanceOf(address(this));
        uint256 ourBalanceOfBBefore = tokenB.balanceOf(address(this));

        // Contract's current balance of A and B
        uint256 contractsBalanceOfABefore = tokenA.balanceOf(address(tokenSwap));
        uint256 contractsBalanceOfBBefore = tokenB.balanceOf(address(tokenSwap));

        // Give approval so that the contract can spend my token A amount
        tokenA.approve(address(tokenSwap), testAmount);

        // Perform the swap
        tokenSwap.swapAtoB(testAmount);

        // Post checks on us
        assertEq(tokenA.balanceOf(address(this)), ourBalanceOfABefore - testAmount);
        assertEq(tokenB.balanceOf(address(this)), ourBalanceOfBBefore + testAmount);

        // Post checks on contract
        assertEq(tokenB.balanceOf(address(tokenSwap)), contractsBalanceOfBBefore - testAmount);
        assertEq(tokenA.balanceOf(address(tokenSwap)), contractsBalanceOfABefore + testAmount);
    }

    function test_FuzzSwapBtoA(uint256 testAmount) public {
        // We will provide only values higher than zero and within the balance of the contract
        vm.assume(testAmount > 0);
        vm.assume(testAmount <= tokenA.balanceOf(address(tokenSwap)));

        // Our current balances of A and B
        uint256 ourBalanceOfABefore = tokenA.balanceOf(address(this));
        uint256 ourBalanceOfBBefore = tokenB.balanceOf(address(this));

        // Contract's current balance of A and B
        uint256 contractsBalanceOfABefore = tokenA.balanceOf(address(tokenSwap));
        uint256 contractsBalanceOfBBefore = tokenB.balanceOf(address(tokenSwap));

        // Give approval so that the contract can spend my token B amount
        tokenB.approve(address(tokenSwap), testAmount);

        // Perform the swap
        tokenSwap.swapBtoA(testAmount);

        // Post checks on us
        assertEq(tokenB.balanceOf(address(this)), ourBalanceOfBBefore - testAmount);
        assertEq(tokenA.balanceOf(address(this)), ourBalanceOfABefore + testAmount);

        // Post checks on contract
        assertEq(tokenA.balanceOf(address(tokenSwap)), contractsBalanceOfABefore - testAmount);
        assertEq(tokenB.balanceOf(address(tokenSwap)), contractsBalanceOfBBefore + testAmount);
    }
}
