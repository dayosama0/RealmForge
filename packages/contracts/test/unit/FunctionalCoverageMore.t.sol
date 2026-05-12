// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {BlockCraftItems} from "../../src/tokens/BlockCraftItems.sol";
import {CraftToken} from "../../src/tokens/CraftToken.sol";
import {CraftingManager} from "../../src/crafting/CraftingManager.sol";
import {CraftingManagerV2} from "../../src/crafting/CraftingManagerV2.sol";
import {ResourceAMMFactory} from "../../src/amm/ResourceAMMFactory.sol";
import {ResourcePair} from "../../src/amm/ResourcePair.sol";
import {LootBox} from "../../src/loot/LootBox.sol";
import {CraftPriceOracle} from "../../src/oracle/CraftPriceOracle.sol";
import {RentalFeeVault} from "../../src/vault/RentalFeeVault.sol";
import {ItemRentalVault} from "../../src/vault/ItemRentalVault.sol";
import {BlockCraftTimelock} from "../../src/governance/BlockCraftTimelock.sol";
import {BlockCraftGovernor} from "../../src/governance/BlockCraftGovernor.sol";
import {Treasury} from "../../src/governance/Treasury.sol";
import {GameModuleFactory} from "../../src/factory/GameModuleFactory.sol";
import {MockAggregatorV3} from "../../src/mocks/MockAggregatorV3.sol";
import {MockVRFCoordinator} from "../../src/mocks/MockVRFCoordinator.sol";

contract FunctionalCoverageMoreTest is Test {
    address player = address(0xBEEF);
    address renter = address(0xCAFE);
    BlockCraftItems items;
    CraftToken craft;
    CraftingManager crafting;
    ResourceAMMFactory factory;
    MockAggregatorV3 feed;
    CraftPriceOracle oracle;
    MockVRFCoordinator vrf;
    Treasury treasury;
    LootBox loot;
    RentalFeeVault feeVault;
    ItemRentalVault rental;

    function setUp() public {
        craft = new CraftToken(address(this), 1_000_000 ether);
        items = new BlockCraftItems("", address(this));
        CraftingManager impl = new CraftingManager();
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(impl),
            abi.encodeCall(CraftingManager.initialize, (address(items), address(this)))
        );
        crafting = CraftingManager(address(proxy));
        items.grantRole(items.MINTER_ROLE(), address(crafting));
        items.grantRole(items.BURNER_ROLE(), address(crafting));
        items.grantRole(items.MINTER_ROLE(), address(this));
        factory = new ResourceAMMFactory(address(items), address(this));
        feed = new MockAggregatorV3(8, 1e8);
        oracle = new CraftPriceOracle(address(feed), 1 days, address(this));
        treasury = new Treasury(address(this));
        feeVault = new RentalFeeVault(craft, address(this));
        rental = new ItemRentalVault(address(items), address(craft), address(feeVault), address(this));
        vrf = new MockVRFCoordinator();
        loot = new LootBox(address(craft), address(items), address(oracle), address(vrf), address(treasury), address(this));
        vrf.setConsumer(address(loot));
        items.grantRole(items.MINTER_ROLE(), address(loot));
        craft.transfer(player, 10_000 ether);
        craft.transfer(renter, 10_000 ether);
    }

    receive() external payable {}

    function _mintResources(address to) internal {
        items.mint(to, items.WOOD(), 1_000, "");
        items.mint(to, items.STONE(), 1_000, "");
        items.mint(to, items.IRON_INGOT(), 1_000, "");
        items.mint(to, items.DIAMOND(), 1_000, "");
        items.mint(to, items.REDSTONE(), 1_000, "");
    }

    function _pairWithLiquidity() internal returns (ResourcePair pair) {
        _mintResources(player);
        pair = ResourcePair(factory.createPair(items.WOOD(), items.STONE()));
        vm.startPrank(player);
        items.setApprovalForAll(address(pair), true);
        pair.addLiquidity(500, 500, 1);
        vm.stopPrank();
    }

    function test061ItemsMintBatchAndBurnBatch() public {
        uint256[] memory ids = new uint256[](2);
        uint256[] memory amounts = new uint256[](2);
        ids[0] = items.WOOD();
        ids[1] = items.STONE();
        amounts[0] = 7;
        amounts[1] = 9;
        items.mintBatch(player, ids, amounts, "");
        items.grantRole(items.BURNER_ROLE(), address(this));
        items.burnBatchFrom(player, ids, amounts);
        assertEq(items.balanceOf(player, items.WOOD()), 0);
    }

    function test062ItemsUnpauseAndSupportsInterface() public {
        items.pause();
        items.unpause();
        assertTrue(items.supportsInterface(type(IERC165).interfaceId));
    }

    function test063ResourcePairRemoveLiquidityAndQuote() public {
        ResourcePair pair = _pairWithLiquidity();
        uint256 amountOut = pair.getAmountOut(items.WOOD(), 10);
        assertGt(amountOut, 0);
        vm.prank(player);
        pair.removeLiquidity(100, 1, 1);
        (uint256 r0, uint256 r1) = pair.getReserves();
        assertLt(r0 + r1, 1_000);
    }

    function test064ResourcePairUnpauseAndSupportsInterface() public {
        ResourcePair pair = _pairWithLiquidity();
        pair.pause();
        pair.unpause();
        assertTrue(pair.supportsInterface(type(IERC165).interfaceId));
    }

    function test065ResourcePairExposesSortedTokenIds() public {
        ResourcePair pair = ResourcePair(factory.createPair(items.WOOD(), items.STONE()));
        assertEq(pair.token0Id(), items.WOOD());
        assertEq(pair.token1Id(), items.STONE());
    }

    function test066CraftingV2BatchCraft() public {
        CraftingManagerV2 impl = new CraftingManagerV2();
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(impl),
            abi.encodeCall(CraftingManager.initialize, (address(items), address(this)))
        );
        CraftingManagerV2 v2 = CraftingManagerV2(address(proxy));
        items.grantRole(items.MINTER_ROLE(), address(v2));
        items.grantRole(items.BURNER_ROLE(), address(v2));
        _mintResources(player);
        uint256[] memory craftIds = new uint256[](2);
        craftIds[0] = items.IRON_PICKAXE();
        craftIds[1] = items.DIAMOND_SWORD();
        vm.prank(player);
        v2.batchCraft(craftIds);
        assertEq(items.balanceOf(player, items.IRON_PICKAXE()), 1);
        assertEq(items.balanceOf(player, items.DIAMOND_SWORD()), 1);
    }

    function test067OracleSetFeedAndRejectsStalePrice() public {
        MockAggregatorV3 freshFeed = new MockAggregatorV3(8, 2e8);
        oracle.setFeed(address(freshFeed));
        assertEq(oracle.quoteUsdToToken(2e8), 1e8);
        vm.warp(3 days);
        freshFeed.setUpdatedAt(block.timestamp - 2 days);
        vm.expectRevert();
        oracle.latestPrice();
    }

    function test068OracleRejectsInvalidPriceAndZeroFeed() public {
        feed.setAnswer(0);
        vm.expectRevert();
        oracle.latestPrice();
        vm.expectRevert();
        oracle.setFeed(address(0));
    }

    function test069LootSetOracleTreasuryPauseUnpause() public {
        loot.setTreasury(player);
        loot.setOracle(address(oracle));
        loot.pause();
        assertTrue(loot.paused());
        loot.unpause();
        assertFalse(loot.paused());
        assertEq(loot.treasury(), player);
    }

    function test070LootRewardBuckets() public {
        vm.startPrank(player);
        craft.approve(address(loot), type(uint256).max);
        uint256 id1 = loot.openLootBox();
        uint256 id2 = loot.openLootBox();
        uint256 id3 = loot.openLootBox();
        uint256 id4 = loot.openLootBox();
        vm.stopPrank();
        vrf.fulfill(id1, 40);
        vrf.fulfill(id2, 80);
        vrf.fulfill(id3, 96);
        vrf.fulfill(id4, 98);
        assertGt(items.balanceOf(player, items.IRON_INGOT()), 0);
        assertGt(items.balanceOf(player, items.REDSTONE()), 0);
        assertGt(items.balanceOf(player, items.ENCHANTED_BOOK()), 0);
        assertGt(items.balanceOf(player, items.ELYTRA()), 0);
    }

    function test071RentalReturnItemAndPauseUnpause() public {
        items.mint(player, items.ELYTRA(), 1, "");
        vm.startPrank(player);
        items.setApprovalForAll(address(rental), true);
        uint256 id = rental.depositItem(items.ELYTRA(), 1, 1 ether, 1 days);
        vm.stopPrank();
        vm.startPrank(renter);
        craft.approve(address(rental), type(uint256).max);
        rental.rentItem(id, 1 days);
        rental.returnItem(id);
        vm.stopPrank();
        rental.pause();
        rental.unpause();
        assertEq(items.balanceOf(player, items.ELYTRA()), 1);
    }

    function test072RentalRejectsInvalidProtocolFeeAndSupportsInterface() public {
        vm.expectRevert();
        rental.setProtocolFeeBps(2_001);
        assertTrue(rental.supportsInterface(type(IERC165).interfaceId));
    }

    function test073TreasuryWithdrawEth() public {
        (bool sent,) = address(treasury).call{value: 1 ether}("");
        assertTrue(sent);
        uint256 beforeBalance = player.balance;
        treasury.withdrawEth(payable(player), 1 ether);
        assertEq(player.balance, beforeBalance + 1 ether);
    }

    function test074GameModuleFactoryDeployAMMFactory() public {
        GameModuleFactory gm = new GameModuleFactory(address(this));
        address deployed = gm.deployAMMFactory(address(items));
        assertEq(ResourceAMMFactory(deployed).items(), address(items));
    }

    function test075GovernorWrappersAndSupportsInterface() public {
        address[] memory proposers = new address[](1);
        address[] memory executors = new address[](1);
        proposers[0] = address(this);
        executors[0] = address(0);
        BlockCraftTimelock timelock = new BlockCraftTimelock(2 days, proposers, executors, address(this));
        BlockCraftGovernor governor = new BlockCraftGovernor(craft, timelock, 10 ether);
        craft.delegate(address(this));
        vm.roll(block.number + 1);
        assertEq(governor.proposalThreshold(), 10 ether);
        assertEq(governor.quorum(block.number - 1), 40_000 ether);
        assertTrue(governor.supportsInterface(type(IERC165).interfaceId));
    }
}
