// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface ILootConsumer {
    function fulfillRandomWords(uint256 requestId, uint256 randomness) external;
}

contract MockVRFCoordinator {
    uint256 public nextRequestId;
    address public consumer;

    function setConsumer(address consumer_) external {
        consumer = consumer_;
    }

    function requestRandomWords() external returns (uint256 requestId) {
        requestId = ++nextRequestId;
    }

    function fulfill(uint256 requestId, uint256 randomness) external {
        ILootConsumer(consumer).fulfillRandomWords(requestId, randomness);
    }
}
