// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {BlockCraftItems} from "../tokens/BlockCraftItems.sol";
import {CraftPriceOracle} from "../oracle/CraftPriceOracle.sol";
import {Events} from "../utils/Events.sol";
import {Errors} from "../utils/Errors.sol";

interface IVRFCoordinatorLike {
    function requestRandomWords() external returns (uint256 requestId);
}

contract LootBox is AccessControl, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    bytes32 public constant CONFIG_ROLE = keccak256("CONFIG_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    IERC20 public immutable craft;
    BlockCraftItems public immutable items;
    CraftPriceOracle public oracle;
    address public treasury;
    IVRFCoordinatorLike public immutable coordinator;
    uint256 public lootPriceUsd8;

    struct PendingLoot {
        address player;
        bool fulfilled;
    }

    mapping(uint256 => PendingLoot) public pendingLoot;

    constructor(
        address craft_,
        address items_,
        address oracle_,
        address coordinator_,
        address treasury_,
        address admin
    ) {
        craft = IERC20(craft_);
        items = BlockCraftItems(items_);
        oracle = CraftPriceOracle(oracle_);
        coordinator = IVRFCoordinatorLike(coordinator_);
        treasury = treasury_;
        lootPriceUsd8 = 1e8;
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(CONFIG_ROLE, admin);
        _grantRole(PAUSER_ROLE, admin);
    }

    function openLootBox() external nonReentrant whenNotPaused returns (uint256 requestId) {
        uint256 cost = oracle.quoteUsdToToken(lootPriceUsd8);
        craft.safeTransferFrom(msg.sender, treasury, cost);
        requestId = coordinator.requestRandomWords();
        pendingLoot[requestId] = PendingLoot(msg.sender, false);
        emit Events.LootRequested(msg.sender, requestId);
    }

    function fulfillRandomWords(uint256 requestId, uint256 randomness) external {
        require(msg.sender == address(coordinator), "VRF");
        PendingLoot storage pending = pendingLoot[requestId];
        if (pending.player == address(0) || pending.fulfilled) revert Errors.InvalidAmount();
        pending.fulfilled = true;
        (uint256 rewardId, uint256 amount) = _reward(randomness);
        items.mint(pending.player, rewardId, amount, "");
        emit Events.LootFulfilled(pending.player, requestId, rewardId, amount);
    }

    function setLootPriceUsd8(uint256 price) external onlyRole(CONFIG_ROLE) {
        lootPriceUsd8 = price;
    }

    function setOracle(address oracle_) external onlyRole(CONFIG_ROLE) {
        oracle = CraftPriceOracle(oracle_);
    }

    function setTreasury(address treasury_) external onlyRole(CONFIG_ROLE) {
        treasury = treasury_;
    }

    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function _reward(uint256 randomness) internal pure returns (uint256 itemId, uint256 amount) {
        uint256 roll = randomness % 100;
        if (roll < 40) return (roll % 2 == 0 ? 1 : 2, 10);
        if (roll < 65) return (roll % 2 == 0 ? 3 : 4, 5);
        if (roll < 80) return (5, 2);
        if (roll < 90) return (7, 5);
        if (roll < 97) return (104, 1);
        if (roll < 99) return (105, 1);
        return (106, 1);
    }
}
