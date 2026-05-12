// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ResourceAMMFactory} from "../amm/ResourceAMMFactory.sol";
import {Treasury} from "../governance/Treasury.sol";

contract GameModuleFactory is Ownable {
    event AMMFactoryDeployed(address indexed factory);
    event TreasuryDeployed(address indexed treasury);

    constructor(address owner_) Ownable(owner_) {}

    function deployAMMFactory(address items) external onlyOwner returns (address deployed) {
        deployed = address(new ResourceAMMFactory(items, owner()));
        emit AMMFactoryDeployed(deployed);
    }

    function deployTreasury() external onlyOwner returns (address deployed) {
        deployed = address(new Treasury(owner()));
        emit TreasuryDeployed(deployed);
    }
}
