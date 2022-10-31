/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "./Author.sol";

contract AuthorFactory {
    Authors[] public authorAddresses;
    
    event AuthorCreated(Author author);

    address private paperScoreAdmin;
    address private accessMinter;
    address immutable authorImplementation;

    constructor(address _accessMinter, address _paperScoreAdmin) public {
        accessMinter = _accessMinter;
        paperScoreAdmin = _paperScoreAdmin;
        authorImplementation = address(new Author());
    }

    function createAuthor(uint256 initialBalance) external returns(address) {
        address clone = Clones.clone(authorImplementation);
        Author(clone).initialize(accessMinter, "paper-score-api/{id}", msg.sender, paperScoreAdmin);
        emit AuthorCreated(author);
    }

    function getMetaCoins() external view returns (MetaCoin[] memory) {
        return metaCoinAddresses;
    }
}