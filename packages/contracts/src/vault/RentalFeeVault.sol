// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract RentalFeeVault is ERC4626, Ownable {
    constructor(IERC20 asset_, address owner_)
        ERC20("BlockCraft Rental Fee Vault", "bcRENT")
        ERC4626(asset_)
        Ownable(owner_)
    {}
}
