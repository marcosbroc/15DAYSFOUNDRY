// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IPool} from "../lib/protocol-v3/contracts/interfaces/IPool.sol";
import {IWETH} from "../lib/protocol-v3/contracts/misc/interfaces/IWETH.sol";
import {IERC20WithPermit} from "../lib/protocol-v3/contracts/interfaces/IERC20WithPermit.sol";

contract AaveBorrow {
    address public owner;
    IPool public pool;
    IWETH public weth;
    IERC20WithPermit public usdc;

    // Aave v3 Pool (mainnet)
    address constant POOL = 0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2;
    // WETH mainnet
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    // USDC mainnet
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    constructor() {
        owner = msg.sender;
        pool = IPool(POOL);
        weth = IWETH(WETH);
        usdc = IERC20WithPermit(USDC);
    }

    // Deposit ETH into Aave
    function depositETH() external payable {
        require(msg.sender == owner, "Only owner");

        // Wrap ETH to WETH
        weth.deposit{value: msg.value}();
        //Approve Aave pool to pull WETH
        require(weth.approve(address(pool), msg.value), "Approval failed");
        // Supply to Aave
        pool.supply(address(weth), msg.value, address(this), 0);
    }

    function borrowUSDC(uint256 amount) external {
        require(msg.sender == owner, "Only owner");

        // Borrow USDC from Aave
        pool.borrow(address(usdc), amount, 2, 0, address(this));
    }

    function getUSDCBalance() external view returns (uint256) {
        return usdc.balanceOf(address(this));
    }

    function getUserAccountData(address user)
        external
        view
        returns (
            uint256 totalCollateralBase,
            uint256 totalDebtBase,
            uint256 availableBorrowsBase,
            uint256 currentLiquidationThreshold,
            uint256 ltv,
            uint256 healthFactor
        )
    {
        return pool.getUserAccountData(user);
    }

    receive() external payable {}
}
