// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IPriceOracle} from "./IPriceOracle.sol";
import {Errors} from "../utils/Errors.sol";

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);
    function latestRoundData() external view returns (uint80, int256, uint256, uint256, uint80);
}

contract CraftPriceOracle is IPriceOracle, Ownable {
    AggregatorV3Interface public feed;
    uint256 public staleAfter;

    constructor(address feed_, uint256 staleAfter_, address owner_) Ownable(owner_) {
        if (feed_ == address(0)) revert Errors.ZeroAddress();
        feed = AggregatorV3Interface(feed_);
        staleAfter = staleAfter_;
    }

    function setFeed(address feed_) external onlyOwner {
        if (feed_ == address(0)) revert Errors.ZeroAddress();
        feed = AggregatorV3Interface(feed_);
    }

    function setStaleAfter(uint256 staleAfter_) external onlyOwner {
        staleAfter = staleAfter_;
    }

    function latestPrice() public view returns (int256 answer, uint8 decimals_) {
        uint256 updatedAt;
        uint256 startedAt;
        uint80 roundId;
        uint80 answeredInRound;
        (roundId, answer, startedAt, updatedAt, answeredInRound) = feed.latestRoundData();
        if (answer <= 0) revert Errors.InvalidPrice();
        if (startedAt == 0 || updatedAt == 0) revert Errors.InvalidPrice();
        if (answeredInRound < roundId) revert Errors.InvalidPrice();
        if (block.timestamp - updatedAt > staleAfter) revert Errors.StalePrice();
        decimals_ = feed.decimals();
    }

    function quoteUsdToToken(uint256 usdAmount8Decimals) external view returns (uint256 tokenAmount) {
        (int256 answer, uint8 decimals_) = latestPrice();
        uint256 price = uint256(answer);
        return (usdAmount8Decimals * (10 ** decimals_)) / price;
    }
}
