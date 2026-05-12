// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
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

contract BlockCraftCoreTest is Test {
    address player = address(0xBEEF);
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
        ERC1967Proxy proxy = new ERC1967Proxy(address(impl), abi.encodeCall(CraftingManager.initialize, (address(items), address(this))));
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
    }

    function _mintResources(address to) internal {
        items.mint(to, items.WOOD(), 1_000, "");
        items.mint(to, items.STONE(), 1_000, "");
        items.mint(to, items.IRON_INGOT(), 1_000, "");
        items.mint(to, items.GOLD_INGOT(), 1_000, "");
        items.mint(to, items.DIAMOND(), 1_000, "");
        items.mint(to, items.EMERALD(), 1_000, "");
        items.mint(to, items.REDSTONE(), 1_000, "");
    }

    function test001ItemsKnowWood() public { assertEq(items.itemName(items.WOOD()), "WOOD"); }
    function test002ItemsKnowStone() public { assertEq(items.itemName(items.STONE()), "STONE"); }
    function test003ItemsKnowIron() public { assertTrue(items.validItem(items.IRON_INGOT())); }
    function test004ItemsKnowGold() public { assertTrue(items.validItem(items.GOLD_INGOT())); }
    function test005ItemsKnowDiamond() public { assertTrue(items.validItem(items.DIAMOND())); }
    function test006ItemsKnowEmerald() public { assertTrue(items.validItem(items.EMERALD())); }
    function test007ItemsKnowRedstone() public { assertTrue(items.validItem(items.REDSTONE())); }
    function test008ItemsKnowElytra() public { assertTrue(items.validItem(items.ELYTRA())); }
    function test009MintResource() public { items.mint(player, items.WOOD(), 5, ""); assertEq(items.balanceOf(player, items.WOOD()), 5); }
    function test010BurnResource() public { items.mint(player, items.WOOD(), 5, ""); items.grantRole(items.BURNER_ROLE(), address(this)); items.burnFrom(player, items.WOOD(), 2); assertEq(items.balanceOf(player, items.WOOD()), 3); }
    function test011CraftTokenName() public { assertEq(craft.name(), "BlockCraft Token"); }
    function test012CraftTokenSymbol() public { assertEq(craft.symbol(), "CRAFT"); }
    function test013CraftTokenSupply() public { assertEq(craft.totalSupply(), 1_000_000 ether); }
    function test014CraftTokenDelegate() public { craft.delegate(address(this)); assertGt(craft.getVotes(address(this)), 0); }
    function test015CraftTokenMint() public { craft.mint(player, 1 ether); assertEq(craft.balanceOf(player), 10_001 ether); }
    function test016RecipeExistsIronPickaxe() public { (, uint256 out) = crafting.getRecipe(items.IRON_PICKAXE()); assertEq(out, 1); }
    function test017RecipeExistsDiamondPickaxe() public { (, uint256 out) = crafting.getRecipe(items.DIAMOND_PICKAXE()); assertEq(out, 1); }
    function test018CraftIronPickaxe() public { _mintResources(player); vm.startPrank(player); items.setApprovalForAll(address(crafting), true); crafting.craft(items.IRON_PICKAXE()); vm.stopPrank(); assertEq(items.balanceOf(player, items.IRON_PICKAXE()), 1); }
    function test019CraftDiamondPickaxe() public { _mintResources(player); vm.startPrank(player); items.setApprovalForAll(address(crafting), true); crafting.craft(items.DIAMOND_PICKAXE()); vm.stopPrank(); assertEq(items.balanceOf(player, items.DIAMOND_PICKAXE()), 1); }
    function test020CraftDiamondSword() public { _mintResources(player); vm.startPrank(player); items.setApprovalForAll(address(crafting), true); crafting.craft(items.DIAMOND_SWORD()); vm.stopPrank(); assertEq(items.balanceOf(player, items.DIAMOND_SWORD()), 1); }
    function test021CraftingCanPause() public { crafting.pause(); assertTrue(crafting.paused()); }
    function test022CraftingCanUnpause() public { crafting.pause(); crafting.unpause(); assertFalse(crafting.paused()); }
    function test023AMMCreatePair() public { address pair = factory.createPair(items.WOOD(), items.STONE()); assertTrue(pair != address(0)); }
    function test024AMMCreatePair2() public { address pair = factory.createPairDeterministic(items.WOOD(), items.STONE(), keccak256("WOOD_STONE")); assertTrue(pair != address(0)); }
    function test025AMMLength() public { factory.createPair(items.WOOD(), items.STONE()); assertEq(factory.allPairsLength(), 1); }
    function test026AMMAddLiquidity() public { _mintResources(player); address pair = factory.createPair(items.WOOD(), items.STONE()); vm.startPrank(player); items.setApprovalForAll(pair, true); ResourcePair(pair).addLiquidity(100, 100, 1); vm.stopPrank(); (uint256 r0, uint256 r1) = ResourcePair(pair).getReserves(); assertEq(r0 + r1, 200); }
    function test027AMMSwap() public { _mintResources(player); address pair = factory.createPair(items.WOOD(), items.STONE()); vm.startPrank(player); items.setApprovalForAll(pair, true); ResourcePair(pair).addLiquidity(500, 500, 1); ResourcePair(pair).swapExactInput(items.WOOD(), 10, 1); vm.stopPrank(); assertGt(items.balanceOf(player, items.STONE()), 500); }
    function test028OraclePrice() public { (int256 answer, uint8 decimals_) = oracle.latestPrice(); assertEq(answer, 1e8); assertEq(decimals_, 8); }
    function test029OracleQuote() public { assertEq(oracle.quoteUsdToToken(1e8), 1e8); }
    function test030OracleSetStaleness() public { oracle.setStaleAfter(2 days); assertEq(oracle.staleAfter(), 2 days); }
    function test031LootOpen() public { vm.startPrank(player); craft.approve(address(loot), type(uint256).max); uint256 id = loot.openLootBox(); vm.stopPrank(); assertEq(id, 1); }
    function test032LootFulfillWoodStone() public { vm.startPrank(player); craft.approve(address(loot), type(uint256).max); uint256 id = loot.openLootBox(); vm.stopPrank(); vrf.fulfill(id, 1); assertGt(items.balanceOf(player, items.STONE()), 0); }
    function test033LootFulfillDragonEgg() public { vm.startPrank(player); craft.approve(address(loot), type(uint256).max); uint256 id = loot.openLootBox(); vm.stopPrank(); vrf.fulfill(id, 99); assertEq(items.balanceOf(player, items.DRAGON_EGG()), 1); }
    function test034RentalDeposit() public { items.mint(player, items.ELYTRA(), 1, ""); vm.startPrank(player); items.setApprovalForAll(address(rental), true); uint256 id = rental.depositItem(items.ELYTRA(), 1, 1 ether, 1 days); vm.stopPrank(); assertEq(id, 1); }
    function test035RentalRent() public { items.mint(player, items.ELYTRA(), 1, ""); vm.startPrank(player); items.setApprovalForAll(address(rental), true); uint256 id = rental.depositItem(items.ELYTRA(), 1, 1 ether, 1 days); craft.approve(address(rental), type(uint256).max); rental.rentItem(id, 1 days); vm.stopPrank(); (, address renter,,,,,,) = rental.positions(id); assertEq(renter, player); }
    function test036RentalClaim() public { items.mint(player, items.ELYTRA(), 1, ""); address renter = address(0xCAFE); craft.transfer(renter, 2 ether); vm.startPrank(player); items.setApprovalForAll(address(rental), true); uint256 id = rental.depositItem(items.ELYTRA(), 1, 1 ether, 1 days); vm.stopPrank(); vm.startPrank(renter); craft.approve(address(rental), type(uint256).max); rental.rentItem(id, 1 days); vm.stopPrank(); vm.prank(player); rental.claimRentalFees(); assertGt(craft.balanceOf(player), 10_000 ether); }
    function test037FeeVaultAsset() public { assertEq(address(feeVault.asset()), address(craft)); }
    function test038TreasuryOwner() public { assertEq(treasury.owner(), address(this)); }
    function test039TreasuryWithdrawToken() public { craft.transfer(address(treasury), 1 ether); treasury.withdrawToken(address(craft), player, 1 ether); assertGt(craft.balanceOf(player), 10_000 ether); }
    function test040GameModuleFactory() public { GameModuleFactory gm = new GameModuleFactory(address(this)); address t = gm.deployTreasury(); assertTrue(t != address(0)); }
    function test041TimelockDelay() public { address[] memory p = new address[](1); address[] memory e = new address[](1); p[0] = address(this); e[0] = address(0); BlockCraftTimelock tl = new BlockCraftTimelock(2 days, p, e, address(this)); assertEq(tl.getMinDelay(), 2 days); }
    function test042GovernorName() public { address[] memory p = new address[](1); address[] memory e = new address[](1); BlockCraftTimelock tl = new BlockCraftTimelock(2 days, p, e, address(this)); BlockCraftGovernor gov = new BlockCraftGovernor(craft, tl, 10 ether); assertEq(gov.name(), "BlockCraftGovernor"); }
    function test043GovernorVotingDelay() public { address[] memory p = new address[](1); address[] memory e = new address[](1); BlockCraftTimelock tl = new BlockCraftTimelock(2 days, p, e, address(this)); BlockCraftGovernor gov = new BlockCraftGovernor(craft, tl, 10 ether); assertEq(gov.votingDelay(), 1 days); }
    function test044GovernorVotingPeriod() public { address[] memory p = new address[](1); address[] memory e = new address[](1); BlockCraftTimelock tl = new BlockCraftTimelock(2 days, p, e, address(this)); BlockCraftGovernor gov = new BlockCraftGovernor(craft, tl, 10 ether); assertEq(gov.votingPeriod(), 1 weeks); }
    function test045SetRecipe() public { uint256[] memory ids = new uint256[](1); uint256[] memory amounts = new uint256[](1); ids[0] = items.WOOD(); amounts[0] = 1; crafting.setRecipe(items.WOODEN_PICKAXE(), ids, amounts); (, uint256 out) = crafting.getRecipe(items.WOODEN_PICKAXE()); assertEq(out, 1); }
    function test046LootPriceConfig() public { loot.setLootPriceUsd8(2e8); assertEq(loot.lootPriceUsd8(), 2e8); }
    function test047RentalFeeConfig() public { rental.setProtocolFeeBps(500); assertEq(rental.protocolFeeBps(), 500); }
    function test048AMMPause() public { address pair = factory.createPair(items.WOOD(), items.STONE()); ResourcePair(pair).pause(); assertTrue(ResourcePair(pair).paused()); }
    function test049ItemsPause() public { items.pause(); assertTrue(items.paused()); }
    function test050V2Version() public { CraftingManagerV2 v2 = new CraftingManagerV2(); assertEq(v2.version(), "2.0.0"); }
}
