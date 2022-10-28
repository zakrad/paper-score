// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IAccessMinter {
    function submit(uint _paperId, address _author, uint _maxSupply, uint _price) external;
}