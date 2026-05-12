// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ResourcePair} from "./ResourcePair.sol";
import {Events} from "../utils/Events.sol";
import {Errors} from "../utils/Errors.sol";

contract ResourceAMMFactory is Ownable {
    address public immutable items;
    mapping(bytes32 => address) public pairs;
    address[] public allPairs;

    constructor(address itemAddress, address owner_) Ownable(owner_) {
        if (itemAddress == address(0)) revert Errors.ZeroAddress();
        items = itemAddress;
    }

    function createPair(uint256 idA, uint256 idB) external onlyOwner returns (address pair) {
        bytes32 key = _key(idA, idB);
        if (pairs[key] != address(0)) revert Errors.PairExists();
        pair = address(new ResourcePair(items, idA, idB, owner()));
        pairs[key] = pair;
        allPairs.push(pair);
        emit Events.PairCreated(pair, idA, idB, false);
    }

    function createPairDeterministic(uint256 idA, uint256 idB, bytes32 salt) external onlyOwner returns (address pair) {
        bytes32 key = _key(idA, idB);
        if (pairs[key] != address(0)) revert Errors.PairExists();
        pair = address(new ResourcePair{salt: salt}(items, idA, idB, owner()));
        pairs[key] = pair;
        allPairs.push(pair);
        emit Events.PairCreated(pair, idA, idB, true);
    }

    function getPair(uint256 idA, uint256 idB) external view returns (address) {
        return pairs[_key(idA, idB)];
    }

    function allPairsLength() external view returns (uint256) {
        return allPairs.length;
    }

    function _key(uint256 idA, uint256 idB) internal pure returns (bytes32) {
        (uint256 a, uint256 b) = idA < idB ? (idA, idB) : (idB, idA);
        return keccak256(abi.encodePacked(a, b));
    }
}
