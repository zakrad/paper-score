// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract Review is AccessControl {
    bytes32 public constant REVIWER = keccak256("REVIWER");

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        // _grantRole(REVIWER, msg.sender);
    }

    
}
