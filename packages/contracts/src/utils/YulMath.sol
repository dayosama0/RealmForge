// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library YulMath {
    function mulDivDown(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 z) {
        assembly {
            if iszero(denominator) { revert(0, 0) }
            z := div(mul(x, y), denominator)
        }
    }
}
