// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC1155Holder} from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {BlockCraftItems} from "../tokens/BlockCraftItems.sol";
import {RentalFeeVault} from "./RentalFeeVault.sol";
import {Events} from "../utils/Events.sol";
import {Errors} from "../utils/Errors.sol";

contract ItemRentalVault is ERC1155Holder, AccessControl, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    bytes32 public constant CONFIG_ROLE = keccak256("CONFIG_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    enum RentalStatus {
        Available,
        Rented,
        Returned
    }

    struct RentalPosition {
        address lender;
        address renter;
        uint256 itemId;
        uint256 amount;
        uint256 price;
        uint256 maxDuration;
        uint256 expiresAt;
        RentalStatus status;
    }

    BlockCraftItems public immutable items;
    IERC20 public immutable craft;
    RentalFeeVault public immutable feeVault;
    uint256 public protocolFeeBps;
    uint256 public nextPositionId;
    mapping(uint256 => RentalPosition) public positions;
    mapping(address => uint256) public lenderAccrued;

    constructor(address items_, address craft_, address feeVault_, address admin) {
        items = BlockCraftItems(items_);
        craft = IERC20(craft_);
        feeVault = RentalFeeVault(feeVault_);
        protocolFeeBps = 1_000;
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(CONFIG_ROLE, admin);
        _grantRole(PAUSER_ROLE, admin);
    }

    function depositItem(uint256 itemId, uint256 amount, uint256 price, uint256 duration)
        external
        nonReentrant
        whenNotPaused
        returns (uint256 positionId)
    {
        if (!_isRentable(itemId) || amount == 0 || price == 0 || duration == 0) revert Errors.InvalidAmount();
        positionId = ++nextPositionId;
        positions[positionId] = RentalPosition(msg.sender, address(0), itemId, amount, price, duration, 0, RentalStatus.Available);
        items.safeTransferFrom(msg.sender, address(this), itemId, amount, "");
        emit Events.RentalListed(positionId, msg.sender, itemId, price, duration);
    }

    function rentItem(uint256 positionId, uint256 duration) external nonReentrant whenNotPaused {
        RentalPosition storage p = positions[positionId];
        if (p.status != RentalStatus.Available) revert Errors.NotAvailable();
        if (duration == 0 || duration > p.maxDuration) revert Errors.InvalidAmount();
        uint256 fee = Math.mulDiv(p.price, duration, 1 days);
        uint256 protocolFee = Math.mulDiv(fee, protocolFeeBps, 10_000);
        craft.safeTransferFrom(msg.sender, address(this), fee);
        craft.safeTransfer(address(feeVault), protocolFee);
        lenderAccrued[p.lender] += fee - protocolFee;
        p.renter = msg.sender;
        p.expiresAt = block.timestamp + duration;
        p.status = RentalStatus.Rented;
        emit Events.ItemRented(positionId, msg.sender, p.expiresAt);
    }

    function returnItem(uint256 positionId) external nonReentrant {
        RentalPosition storage p = positions[positionId];
        if (p.status != RentalStatus.Rented) revert Errors.NotAvailable();
        require(msg.sender == p.renter || block.timestamp >= p.expiresAt, "RENTER");
        p.status = RentalStatus.Returned;
        items.safeTransferFrom(address(this), p.lender, p.itemId, p.amount, "");
        emit Events.ItemReturned(positionId);
    }

    function claimRentalFees() external nonReentrant {
        uint256 amount = lenderAccrued[msg.sender];
        if (amount == 0) revert Errors.NothingToClaim();
        lenderAccrued[msg.sender] = 0;
        craft.safeTransfer(msg.sender, amount);
    }

    function setProtocolFeeBps(uint256 feeBps) external onlyRole(CONFIG_ROLE) {
        require(feeBps <= 2_000, "FEE");
        protocolFeeBps = feeBps;
    }

    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function _isRentable(uint256 itemId) internal pure returns (bool) {
        return itemId == 102 || itemId == 103 || itemId == 105 || itemId == 106;
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC1155Holder, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
