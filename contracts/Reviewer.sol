// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract Review is AccessControl {
    bytes32 public constant REVIWER = keccak256("REVIWER");

    // Define a public mapping 'reviwers' that maps the address to a reviewer.
    // address => Reviewer
    mapping(address => Reviewer) reviewers;
    mapping(address => bool) reviewerExists;


    struct Reviewer {
        address reviewer;     // Reviewer address
        uint reviewerPoint;   // Reviewer Score
        mapping (uint => bool) allowed; // Allowed ids to review 
        mapping (uint => uint[5]) scores; // Ids to submitted scores
    }

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        // _grantRole(REVIWER, msg.sender);
    }

    // Define a function to add a reviewer
    function addReviewer(address[] memory _reviewers) public onlyRole(DEFAULT_ADMIN_ROLE){
    require(_reviewers.length > 0, 'Array is empty. please add a reviewer public address');
    for (uint256 i = 0; i < _reviewers.length; i++)
        if(!isReviewer(_reviewers[i]) && _reviewers[i] != address(0)){
          reviewerExists[_reviewers[i]] = true;
          reviewers[_reviewers[i]].reviewer = _reviewers[i];     
        }            
    }

    // Define a function to assign paper to reviewer
    function assignPaper(address[] memory _reviewers, uint[] memory _paperIds) public onlyRole(DEFAULT_ADMIN_ROLE){
    require(_reviewers.length > 0 && _paperIds.length > 0, 'You can not send and empty array');
    for (uint256 i = 0; i < _reviewers.length; i++)
        if(isReviewer(_reviewers[i])){
            for(uint256 j = 0; j < _paperIds.length; j++){
                if(!allowed(_reviewers[i], _paperIds[j]))
                reviewers[_reviewers[i]].allowed[_paperIds[j]] = true;
            }
        }            
    }

    //Define a function to submit paper scores
    function submitPaperScore(uint _paperId, uint[5] memory _scores) public {
        require(isReviewer(msg.sender), 'You are not a reviewer');
        require(allowed(msg.sender, _paperId), 'You are not allowed to submit score for this paper');
        reviewers[msg.sender].scores[_paperId] = _scores;
        reviewers[msg.sender].allowed[_paperId] = false;
    }

    //Define a fucntion to pass access to next reviewer
    function passToNextReviewer(uint _paperId, address _nextReviewer) public {
        require(isReviewer(msg.sender), 'You are not a reviewer');
        require(isReviewer(_nextReviewer), 'Given address is not a reviewer');
        require(allowed(msg.sender, _paperId), 'You are not allowed to submit score for this paper');
        reviewers[msg.sender].allowed[_paperId] = false;
        reviewers[_nextReviewer].allowed[_paperId] = true;
    }

    //Define a fucntion to score Reviewer
    function scoreReviewer(address _reviewer, uint _reviewerPoint) public onlyRole(DEFAULT_ADMIN_ROLE){
        require(isReviewer(_reviewer), 'Address is not a reviewer');
        require(_reviewerPoint >= 0 && _reviewerPoint <= 10, 'submit a valid score');
        reviewers[_reviewer].reviewerPoint = _reviewerPoint;     
    }

    

    // Helper function to check if address is Reviewer
    function isReviewer(address _address) public view returns(bool _isReviewer) {
       return reviewerExists[_address];
    }

    // Helper function to check if address is allowed to submit score for paper
    function allowed(address _address, uint _paperId) public view returns(bool _exists){
        return reviewers[_address].allowed[_paperId];
    }
}
