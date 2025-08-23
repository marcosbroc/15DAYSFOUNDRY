// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {AaveBorrow} from "../src/AaveBorrow.sol";
import {IERC20WithPermit} from "../lib/protocol-v3/contracts/interfaces/IERC20WithPermit.sol";

/**
 * This script should be run with --broadcast after launching anvil with an ETH mainnet fork.
 */
contract AaveBorrowScript is Script {
    function run() external {
        // Fund the default sender on fork
        vm.deal(msg.sender, 100 ether);

        vm.startBroadcast();

        AaveBorrow interactor = new AaveBorrow();

        // Deposit 1 ETH
        interactor.depositETH{value: 1 ether}();
        console.log("1 WETH deposited");

        // Borrow 1000 USDC
        interactor.borrowUSDC(1000 * 1e6);
        console.log("USDC borrowed (and added to the contract)", interactor.getUSDCBalance() / 1e6, "USDC");

        // Our current borrow position and health factor
        (uint256 totalCollateral, uint256 totalDebt, uint256 availableBorrow, uint256 liquidationThreshold,,) =
            interactor.getUserAccountData(address(interactor));
        console.log("Total collateral (in USD)", totalCollateral / 1e8);
        console.log("Total debt (in USD)", totalDebt / 1e8);
        console.log("Available to borrow (in USD)", availableBorrow / 1e8);
        console.log("Liquidation threshold", liquidationThreshold / 100, "%");

        vm.stopBroadcast();
    }
}
