// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract PaperScore is ERC1155, AccessControl, ERC1155Supply {
    bytes32 public constant URI_SETTER_ROLE = keccak256("URI_SETTER_ROLE");
    bytes32 public constant AUTHOR = keccak256("AUTHOR");

    // Define Id variable for each paper
    uint paperId = 1;

    // Define a public mapping 'papers' that maps the Id to a paper.
    // uint => Paper
    mapping(uint => Paper) papers;

    // Define a public mapping 'papersHistory' that maps the id to an array of TxHash, that track its journey through paperScore protocol
    // id => string[]
    mapping (uint => string[]) papersHistory;

    // Define enum 'State' with the following values:
    enum State 
    { 
      Submitted,   //0
      Checked,     //1
      UnderReview, //2 
      Reviewed,    //3
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
    event Submitted(uint indexed paperId, string ipfsHash, address[] reviewers);
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
    papers[paperId] = Paper({
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
    emit Submitted(paperId, _ipfsHash, _reviewers);
    // Increment paperId
    paperId++;
  }

  // Define a function 'fetchPaperData' that fetches the data
  function fetchPaperData(uint _paperId) public view returns(
    uint id, 
    address author, 
    string memory title, 
    string memory ipfsHash, 
    uint accessPrice, 
    uint medianScore, 
    State paperState, 
    address[] memory reviewers)
  {
    id = papers[_paperId].paperId;
    author = papers[_paperId].author;
    title = papers[_paperId].title;
    ipfsHash = papers[_paperId].ipfsHash;
    accessPrice = papers[_paperId].accessPrice;
    medianScore = papers[_paperId].medianScore;
    paperState = papers[_paperId].paperState;
    reviewers = papers[_paperId].reviewers;

    return (
      id,
      author,
      title,
      ipfsHash,
      accessPrice,
      medianScore,
      paperState,
      reviewers
    );
  }

   function checkPaper(
    string memory _paperId,
    string memory _ipfsHash,
    address[] memory _reviewers) public   onlyRole(DEFAULT_ADMIN_ROLE)
  {

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
