// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library Errors {
    error ZeroAddress();
    error InvalidItem();
    error InvalidAmount();
    error Unauthorized();
    error RecipeMissing();
    error SlippageExceeded();
    error PairExists();
    error PairMissing();
    error StalePrice();
    error InvalidPrice();
    error NotRentable();
    error NotAvailable();
    error RentalActive();
    error RentalExpired();
    error NothingToClaim();
}
