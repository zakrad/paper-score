/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "./Author.sol";

contract AuthorFactory {
    address[] public authorAddresses;
    
    event AuthorCreated(address author);

    address private paperScoreAdmin;
    address private accessMinter;
    address immutable authorImplementation;

    constructor(address _accessMinter, address _paperScoreAdmin) {
        accessMinter = _accessMinter;
        paperScoreAdmin = _paperScoreAdmin;
        authorImplementation = address(new Author());
    }

    function createAuthor() external returns(address) {
        address clone = Clones.clone(authorImplementation);
        Author(clone).initialize(accessMinter, "https://paper-score-api/{id}", msg.sender, paperScoreAdmin);
        authorAddresses.push(clone);
        emit AuthorCreated(clone);
        return clone;
    }

    function getAuthors() external view returns (address[] memory) {
        return authorAddresses;
    }
}