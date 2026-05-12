// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC1155Holder} from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {BlockCraftItems} from "../tokens/BlockCraftItems.sol";
import {ResourceLPToken} from "./ResourceLPToken.sol";
import {SolidityMath} from "../utils/SolidityMath.sol";
import {Events} from "../utils/Events.sol";
import {Errors} from "../utils/Errors.sol";

contract ResourcePair is ERC1155Holder, ReentrancyGuard, Pausable, AccessControl {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    uint256 public constant FEE_BPS = 30;
    uint256 public constant BPS = 10_000;

    BlockCraftItems public immutable items;
    uint256 public immutable token0Id;
    uint256 public immutable token1Id;
    ResourceLPToken public immutable lpToken;
    uint256 private reserve0;
    uint256 private reserve1;

    constructor(address itemAddress, uint256 id0, uint256 id1, address admin) {
        if (id0 == id1) revert Errors.InvalidItem();
        items = BlockCraftItems(itemAddress);
        (token0Id, token1Id) = id0 < id1 ? (id0, id1) : (id1, id0);
        lpToken = new ResourceLPToken("BlockCraft Resource LP", "bcLP", address(this));
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(PAUSER_ROLE, admin);
    }

    function addLiquidity(uint256 amount0, uint256 amount1, uint256 minLpOut)
        external
        nonReentrant
        whenNotPaused
        returns (uint256 lpOut)
    {
        if (amount0 == 0 || amount1 == 0) revert Errors.InvalidAmount();
        uint256 supply = lpToken.totalSupply();
        lpOut = supply == 0
            ? SolidityMath.sqrt(amount0 * amount1)
            : SolidityMath.min((amount0 * supply) / reserve0, (amount1 * supply) / reserve1);
        if (lpOut < minLpOut) revert Errors.SlippageExceeded();

        reserve0 += amount0;
        reserve1 += amount1;
        items.safeTransferFrom(msg.sender, address(this), token0Id, amount0, "");
        items.safeTransferFrom(msg.sender, address(this), token1Id, amount1, "");
        lpToken.mint(msg.sender, lpOut);
        emit Events.LiquidityAdded(msg.sender, amount0, amount1, lpOut);
    }

    function removeLiquidity(uint256 lpAmount, uint256 minAmount0, uint256 minAmount1)
        external
        nonReentrant
        whenNotPaused
        returns (uint256 amount0, uint256 amount1)
    {
        uint256 supply = lpToken.totalSupply();
        if (lpAmount == 0 || supply == 0) revert Errors.InvalidAmount();
        amount0 = (lpAmount * reserve0) / supply;
        amount1 = (lpAmount * reserve1) / supply;
        if (amount0 < minAmount0 || amount1 < minAmount1) revert Errors.SlippageExceeded();

        reserve0 -= amount0;
        reserve1 -= amount1;
        lpToken.burn(msg.sender, lpAmount);
        items.safeTransferFrom(address(this), msg.sender, token0Id, amount0, "");
        items.safeTransferFrom(address(this), msg.sender, token1Id, amount1, "");
        emit Events.LiquidityRemoved(msg.sender, amount0, amount1, lpAmount);
    }

    function swapExactInput(uint256 tokenInId, uint256 amountIn, uint256 minAmountOut)
        external
        nonReentrant
        whenNotPaused
        returns (uint256 amountOut)
    {
        if (amountIn == 0) revert Errors.InvalidAmount();
        bool zeroForOne = tokenInId == token0Id;
        if (!zeroForOne && tokenInId != token1Id) revert Errors.InvalidItem();
        uint256 tokenOutId = zeroForOne ? token1Id : token0Id;
        amountOut = getAmountOut(tokenInId, amountIn);
        if (amountOut < minAmountOut) revert Errors.SlippageExceeded();

        if (zeroForOne) {
            reserve0 += amountIn;
            reserve1 -= amountOut;
        } else {
            reserve1 += amountIn;
            reserve0 -= amountOut;
        }
        items.safeTransferFrom(msg.sender, address(this), tokenInId, amountIn, "");
        items.safeTransferFrom(address(this), msg.sender, tokenOutId, amountOut, "");
        emit Events.Swap(msg.sender, tokenInId, tokenOutId, amountIn, amountOut);
    }

    function getAmountOut(uint256 tokenInId, uint256 amountIn) public view returns (uint256) {
        bool zeroForOne = tokenInId == token0Id;
        if (!zeroForOne && tokenInId != token1Id) revert Errors.InvalidItem();
        (uint256 reserveIn, uint256 reserveOut) = zeroForOne ? (reserve0, reserve1) : (reserve1, reserve0);
        if (reserveIn == 0 || reserveOut == 0) revert Errors.InvalidAmount();
        uint256 amountInWithFee = amountIn * (BPS - FEE_BPS);
        return (amountInWithFee * reserveOut) / (reserveIn * BPS + amountInWithFee);
    }

    function getReserves() external view returns (uint256, uint256) {
        return (reserve0, reserve1);
    }

    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC1155Holder, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
