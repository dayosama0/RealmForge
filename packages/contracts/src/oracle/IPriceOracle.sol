// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IPriceOracle {
    function latestPrice() external view returns (int256 answer, uint8 decimals);
    function quoteUsdToToken(uint256 usdAmount8Decimals) external view returns (uint256 tokenAmount);
}
