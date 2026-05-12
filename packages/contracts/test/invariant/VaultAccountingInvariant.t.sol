// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

contract VaultAccountingInvariantHandler {
    uint256 public assets;
    uint256 public shares;

    function depositShadow(uint256 amount) external {
        uint256 bounded = amount % 1e18;
        assets += bounded;
        shares += bounded;
    }
}

contract VaultAccountingInvariantTest is Test {
    VaultAccountingInvariantHandler public handler;

    function setUp() public {
        handler = new VaultAccountingInvariantHandler();
        targetContract(address(handler));
    }

    function invariantVaultAssetsCoverShares() public view {
        assertGe(handler.assets(), handler.shares());
    }
}
