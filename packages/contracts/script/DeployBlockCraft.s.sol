// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {BlockCraftItems} from "../src/tokens/BlockCraftItems.sol";
import {CraftToken} from "../src/tokens/CraftToken.sol";
import {CraftingManager} from "../src/crafting/CraftingManager.sol";
import {ResourceAMMFactory} from "../src/amm/ResourceAMMFactory.sol";
import {ResourcePair} from "../src/amm/ResourcePair.sol";
import {LootBox} from "../src/loot/LootBox.sol";
import {CraftPriceOracle} from "../src/oracle/CraftPriceOracle.sol";
import {RentalFeeVault} from "../src/vault/RentalFeeVault.sol";
import {ItemRentalVault} from "../src/vault/ItemRentalVault.sol";
import {BlockCraftTimelock} from "../src/governance/BlockCraftTimelock.sol";
import {BlockCraftGovernor} from "../src/governance/BlockCraftGovernor.sol";
import {Treasury} from "../src/governance/Treasury.sol";
import {MockAggregatorV3} from "../src/mocks/MockAggregatorV3.sol";
import {MockVRFCoordinator} from "../src/mocks/MockVRFCoordinator.sol";

contract DeployBlockCraft is Script {
    function run() external {
        address deployer = msg.sender;
        vm.startBroadcast();

        CraftToken craft = new CraftToken(deployer, 1_000_000 ether);
        BlockCraftItems items = new BlockCraftItems("ipfs://blockcraft/{id}.json", deployer);
        MockAggregatorV3 feed = new MockAggregatorV3(8, 1e8);
        CraftPriceOracle oracle = new CraftPriceOracle(address(feed), 1 days, deployer);
        MockVRFCoordinator vrf = new MockVRFCoordinator();
        Treasury treasury = new Treasury(deployer);
        RentalFeeVault feeVault = new RentalFeeVault(craft, deployer);
        ItemRentalVault rental = new ItemRentalVault(address(items), address(craft), address(feeVault), deployer);
        LootBox loot = new LootBox(address(craft), address(items), address(oracle), address(vrf), address(treasury), deployer);
        vrf.setConsumer(address(loot));
        ResourceAMMFactory ammFactory = new ResourceAMMFactory(address(items), deployer);
        address woodStonePair = ammFactory.createPair(1, 2);

        CraftingManager implementation = new CraftingManager();
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementation),
            abi.encodeCall(CraftingManager.initialize, (address(items), deployer))
        );

        address[] memory proposers = new address[](0);
        address[] memory executors = new address[](1);
        executors[0] = address(0);
        BlockCraftTimelock timelock = new BlockCraftTimelock(2 days, proposers, executors, deployer);
        BlockCraftGovernor governor = new BlockCraftGovernor(craft, timelock, 10_000 ether);

        items.grantRole(items.MINTER_ROLE(), address(proxy));
        items.grantRole(items.BURNER_ROLE(), address(proxy));
        items.grantRole(items.MINTER_ROLE(), address(loot));
        craft.delegate(deployer);
        items.mint(deployer, 1, 20_000, "");
        items.mint(deployer, 2, 20_000, "");
        items.mint(deployer, 3, 1_000, "");
        items.mint(deployer, 5, 1_000, "");
        items.mint(deployer, 7, 1_000, "");
        items.mint(deployer, 105, 1, "");
        items.setApprovalForAll(woodStonePair, true);
        items.setApprovalForAll(address(rental), true);
        craft.approve(address(loot), type(uint256).max);
        craft.approve(address(rental), type(uint256).max);
        ResourcePair(woodStonePair).addLiquidity(10_000, 10_000, 1);

        treasury.transferOwnership(address(timelock));
        oracle.transferOwnership(address(timelock));
        ammFactory.transferOwnership(address(timelock));
        feeVault.transferOwnership(address(timelock));

        bytes32 proposerRole = timelock.PROPOSER_ROLE();
        bytes32 cancellerRole = timelock.CANCELLER_ROLE();
        bytes32 adminRole = timelock.DEFAULT_ADMIN_ROLE();
        timelock.grantRole(proposerRole, address(governor));
        timelock.grantRole(cancellerRole, address(governor));
        timelock.revokeRole(adminRole, deployer);

        CraftingManager(address(proxy)).grantRole(CraftingManager(address(proxy)).CONFIG_ROLE(), address(timelock));
        CraftingManager(address(proxy)).grantRole(CraftingManager(address(proxy)).UPGRADER_ROLE(), address(timelock));
        CraftingManager(address(proxy)).grantRole(CraftingManager(address(proxy)).PAUSER_ROLE(), address(timelock));
        loot.grantRole(loot.CONFIG_ROLE(), address(timelock));
        loot.grantRole(loot.PAUSER_ROLE(), address(timelock));
        rental.grantRole(rental.CONFIG_ROLE(), address(timelock));
        rental.grantRole(rental.PAUSER_ROLE(), address(timelock));

        string memory deployment = "deployment";
        vm.serializeAddress(deployment, "craftToken", address(craft));
        vm.serializeAddress(deployment, "items", address(items));
        vm.serializeAddress(deployment, "craftingProxy", address(proxy));
        vm.serializeAddress(deployment, "craftingImplementation", address(implementation));
        vm.serializeAddress(deployment, "ammFactory", address(ammFactory));
        vm.serializeAddress(deployment, "woodStonePair", woodStonePair);
        vm.serializeAddress(deployment, "priceOracle", address(oracle));
        vm.serializeAddress(deployment, "vrfCoordinator", address(vrf));
        vm.serializeAddress(deployment, "treasury", address(treasury));
        vm.serializeAddress(deployment, "rentalFeeVault", address(feeVault));
        vm.serializeAddress(deployment, "itemRentalVault", address(rental));
        vm.serializeAddress(deployment, "lootBox", address(loot));
        vm.serializeAddress(deployment, "timelock", address(timelock));
        string memory json = vm.serializeAddress(deployment, "governor", address(governor));
        vm.writeJson(json, "../../apps/web/public/deployments/31337.json");

        rental;
        vm.stopBroadcast();
    }
}
