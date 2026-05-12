// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {ERC1155Burnable} from "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";

contract BlockCraftItems is ERC1155, ERC1155Burnable, AccessControl, Pausable {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    uint256 public constant WOOD = 1;
    uint256 public constant STONE = 2;
    uint256 public constant IRON_INGOT = 3;
    uint256 public constant GOLD_INGOT = 4;
    uint256 public constant DIAMOND = 5;
    uint256 public constant EMERALD = 6;
    uint256 public constant REDSTONE = 7;
    uint256 public constant WOODEN_PICKAXE = 100;
    uint256 public constant IRON_PICKAXE = 101;
    uint256 public constant DIAMOND_PICKAXE = 102;
    uint256 public constant DIAMOND_SWORD = 103;
    uint256 public constant ENCHANTED_BOOK = 104;
    uint256 public constant ELYTRA = 105;
    uint256 public constant DRAGON_EGG = 106;

    mapping(uint256 => bool) public validItem;
    mapping(uint256 => string) public itemName;

    constructor(string memory baseUri, address admin) ERC1155(baseUri) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(MINTER_ROLE, admin);
        _grantRole(BURNER_ROLE, admin);
        _grantRole(PAUSER_ROLE, admin);

        _register(WOOD, "WOOD");
        _register(STONE, "STONE");
        _register(IRON_INGOT, "IRON_INGOT");
        _register(GOLD_INGOT, "GOLD_INGOT");
        _register(DIAMOND, "DIAMOND");
        _register(EMERALD, "EMERALD");
        _register(REDSTONE, "REDSTONE");
        _register(WOODEN_PICKAXE, "WOODEN_PICKAXE");
        _register(IRON_PICKAXE, "IRON_PICKAXE");
        _register(DIAMOND_PICKAXE, "DIAMOND_PICKAXE");
        _register(DIAMOND_SWORD, "DIAMOND_SWORD");
        _register(ENCHANTED_BOOK, "ENCHANTED_BOOK");
        _register(ELYTRA, "ELYTRA");
        _register(DRAGON_EGG, "DRAGON_EGG");
    }

    function mint(address to, uint256 id, uint256 amount, bytes memory data) external onlyRole(MINTER_ROLE) {
        require(validItem[id], "ITEM");
        _mint(to, id, amount, data);
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        external
        onlyRole(MINTER_ROLE)
    {
        for (uint256 i = 0; i < ids.length; i++) require(validItem[ids[i]], "ITEM");
        _mintBatch(to, ids, amounts, data);
    }

    function burnFrom(address from, uint256 id, uint256 amount) external onlyRole(BURNER_ROLE) {
        _burn(from, id, amount);
    }

    function burnBatchFrom(address from, uint256[] memory ids, uint256[] memory amounts) external onlyRole(BURNER_ROLE) {
        _burnBatch(from, ids, amounts);
    }

    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function _register(uint256 id, string memory name_) internal {
        validItem[id] = true;
        itemName[id] = name_;
    }

    function _update(address from, address to, uint256[] memory ids, uint256[] memory values)
        internal
        override
        whenNotPaused
    {
        super._update(from, to, ids, values);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
