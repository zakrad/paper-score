// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "./IAccessMinter.sol";

contract AccessMinter is ERC1155, Ownable, ERC1155Supply, IAccessMinter {

    mapping(uint => mapping(address => uint)) balances;
    mapping(uint => address) author;
    mapping(uint => uint) supply;
    mapping(uint => uint) price;

    event submitted(uint indexed paperId);
    event nftMinted(address minter, uint indexed paperId);

    modifier checkSupply(uint _paperId) {
        require(supply[_paperId] > 0 , "There is not Access nft left to mint");
        _;
    }

    constructor() ERC1155("https://paperscore-metadata-api/{id}") {}

    //Needs modification to ensure just Caller contract can access it
    function submit(uint _paperId, address _author, uint _maxSupply, uint _price) external override {
        balances[_paperId][_author] = 0;
        author[_paperId] = _author;
        supply[_paperId] = _maxSupply;
        price[_paperId] = _price;
        emit submitted(_paperId);
    }

    function mintAccess(uint _paperId) checkSupply(_paperId) payable public {
        require(price[_paperId] == msg.value, 'Please send exact amount of ETHER');
        balances[_paperId][author[_paperId]] += msg.value;
        supply[_paperId]--;
        _mint(msg.sender, _paperId, 1, '');
        emit nftMinted(msg.sender, _paperId);
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        override(ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
