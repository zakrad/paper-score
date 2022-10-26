// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract PaperScore is ERC1155, AccessControl, ERC1155Supply {
    bytes32 public constant URI_SETTER_ROLE = keccak256("URI_SETTER_ROLE");
    bytes32 public constant AUTHOR = keccak256("AUTHOR");
    bytes32 public constant REVIWER = keccak256("REVIWER");

    // Define Id variable for each paper
    uint paperId = 1;

    // Define a public mapping 'papers' that maps the Id to a paper.
    // uint => Item
    mapping(uint => paper) papers;

    // Define a public mapping 'papersHistory' that maps the id to an array of TxHash, that track its journey through paperScore protocol
    // id => string[]
    mapping (uint => string[]) papersHistory;

    // Define enum 'State' with the following values:
    enum State 
    { 
      Submitted,   //0
      Checked,     //1
      UnderReview, //2 
      Reviwed,     //3
      Published    //4
    }

    // Define a default state with submitted state:
    State constant defaultState = State.Submitted;

    // Define a struct 'paper' with the following fields:
    struct Paper {
        uint paperId;        // Paper ID
        address author;      // Author address
        string title;        // Paper title
        string ipfsHash;     // Ipfs address of paper
        uint accessPrice;    // Price to mint an access NFT
        uint medianScore;    // Median score of paper calculated by PaperScore
        State paperState;    // Paper State as represented in the enum State
        address[] reviewers; // Array of reviewers 
    }

    // Define 5 events with the same 5 state values and accept 'paperId' as input argument
    event Submitted(uint paperId, string ipfsHash, );
    event Checked(uint paperId);
    event UnderReview(uint paperId);
    event Reviwed(uint paperId);
    event Published(uint paperId);

    // Modifiers
    // Define a modifier that checks if a paper.state of a paperId is Submitted
    modifier submitted(uint _paperId) {
      require(papers[_paperId].paperState == State.Submitted, "This paper hasn't been submitted yet.");
      _;
    }

    // Define a modifier that checks if a paper.state of a paperId is Checked
    modifier checked(uint _paperId) {
      require(papers[_paperId].paperState == State.Checked, "This paper hasn't been checked yet.");
      _;
    }

    // Define a modifier that checks if a paper.state of a paperId is underReview
    modifier underReview(uint _paperId) {
      require(papers[_paperId].paperState == State.UnderReview, "This paper is still under review.");
      _;
    }

    // Define a modifier that checks if a paper.state of a paperId is Reviewed
    modifier reviewed(uint _paperId) {
      require(papers[_paperId].paperState == State.Reviewed, "This paper hasn't been reviewed yet.");
      _;
    }

    // Define a modifier that checks if a paper.state of a paperId is Reviewed
    modifier published(uint _paperId) {
      require(papers[_paperId].paperState == State.Published, "This paper hasn't been published yet.");
      _;
    }

    // In the constructor set 'admin' to the address that instantiated the contract
    constructor() ERC1155("https://paperscore-metadata-api/{id}") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(URI_SETTER_ROLE, msg.sender);
        _grantRole(AUTHOR, msg.sender);
        // _grantRole(REVIWER, msg.sender);
    }
    
   // Functions //
   // Define a function 'submitPaper' that allows an author to mark an item 'Submitted'

   function submitPaper(
    string memory _title,
    string memory _ipfsHash,
    address[] memory _reviewers) public payable onlyRole(AUTHOR)
  {
    // require(hasRole(AUTHOR, msg.sender), "You are not the author");
    // Add the new paper
    items[paperId] = Paper({
        // Paper ID:
        paperId: paperId,
        // Author address:
        author: msg.sender,
        // Title:
        title: _title,
        // Ipfs Address of paper:
        ipfsHash: _ipfsHash,
        // Paper price to mint access NFT:
        accessPrice: uint(0),
        // Median Score::
        medianScore: uint(0),
        // Paper state:
        paperState: defaultState,
        // Suggested reviewers by author:
        reviewers: _reviewers
        });

    // Emit submit event
    emit Submitted(paperId, ipfsHash, paperState, reviewers);
    // Increment paperId
    paperId++;
  }
    


    function setURI(string memory newuri) public onlyRole(URI_SETTER_ROLE) {
        _setURI(newuri);
    }

    function mint(address account, uint256 id, uint256 amount, bytes memory data)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        _mint(account, id, amount, data);
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        _mintBatch(to, ids, amounts, data);
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
        override(ERC1155, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
