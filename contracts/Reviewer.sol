// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract Review is AccessControl {
    bytes32 public constant REVIWER = keccak256("REVIWER");

    // Define a public mapping 'reviwers' that maps the address to a reviewer.
    // address => Reviewer
    mapping(address => Reviewer) reviewers;

    struct Reviewer {
        address reviewer;     // Reviewer address
        uint reviewerScore;   // Reviewer Score
        uint[] allowToReview; // Array of paper ids to review 
    }


    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        // _grantRole(REVIWER, msg.sender);
    }

    // Define a function to add a reviewer
    function addReviewer(address[] memory _reviewers, uint[] memory _paperIds) public onlyRole(DEFAULT_ADMIN_ROLE)
    {
    for (uint256 i = 0; i < _reviewers.length; i++)
      {
        reviewers[_reviewers[i]].reviewer = _reviewers[i];
        reviewers[_reviewers[i]].reviewerScore = uint(0);
        for (uint256 j = 0; j < _paperIds.length; j++)
            reviewers[_reviewers[i]].allowToReview.push(_paperIds[j]);        
      }
    }
}
