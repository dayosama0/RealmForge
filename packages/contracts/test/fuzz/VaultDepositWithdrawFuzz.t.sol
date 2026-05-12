// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {CraftToken} from "../../src/tokens/CraftToken.sol";
import {RentalFeeVault} from "../../src/vault/RentalFeeVault.sol";

contract VaultDepositWithdrawFuzzTest is Test {
    CraftToken craft;
    RentalFeeVault vault;
    address user = address(0xCAFE);

    function setUp() public {
        craft = new CraftToken(address(this), 1_000_000 ether);
        vault = new RentalFeeVault(craft, address(this));
        craft.transfer(user, 1_000 ether);
    }

    function testFuzzDeposit(uint96 amount) public {
        amount = uint96(bound(amount, 1, 1_000 ether));
        vm.startPrank(user);
        craft.approve(address(vault), amount);
        uint256 shares = vault.deposit(amount, user);
        vm.stopPrank();
        assertGt(shares, 0);
    }

    function testFuzzMint(uint96 shares) public {
        shares = uint96(bound(shares, 1, 100 ether));
        vm.startPrank(user);
        craft.approve(address(vault), type(uint256).max);
        uint256 assets = vault.mint(shares, user);
        vm.stopPrank();
        assertGt(assets, 0);
    }
}
