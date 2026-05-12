// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface ILootBox {
    function openLootBox() external returns (uint256 requestId);
}
