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
      Reviewed,    //1
      Published,   //2
    }

    // Define a default state with submitted state:
    State constant defaultState = State.Submitted;

    // Define a struct 'paper' with the following fields:
    struct Paper {
        uint paperId;        // Paper ID
        address author;      // Author address
        string title;        // Paper title
        string ipfsHash;     // Ipfs address of paper
        string comments;     // Ipfs address of paper
        uint accessPrice;    // Price to mint an access NFT
        uint paperScore;    // Median score of paper calculated by PaperScore
        State paperState;    // Paper State as represented in the enum State
        address[] reviewers; // Array of reviewers 
    }

    // Define 5 events with the same 5 state values and accept 'paperId' as input argument
    event PaperSubmitted(uint indexed paperId, string ipfsHash, address[] reviewers);
    event ScoreSubmitted(uint indexed paperId, uint paperScore, string comments);
    event Published(uint paperId);

    // Modifiers
    // Define a modifier that checks if a paper.state of a paperId is Submitted
    modifier submitted(uint _paperId) {
      require(papers[_paperId].paperState == State.Submitted, "This paper hasn't been submitted yet.");
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
    
    // Define a modifier that checks if a paper id is valid
    modifier correctId(uint _paperId) {
        require(_paperId <= paperId && _paperId>0, "Please provider a correct paper id");
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
    uint _accessPrice,
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
        // Reviewers comments:
        comments: '',
        // Paper price to mint access NFT:
        accessPrice: _accessPrice,
        // Paper Score::
        paperScore: uint(0),
        // Paper state:
        paperState: defaultState,
        // Suggested reviewers by author:
        reviewers: _reviewers
        });

    // Emit submit event
    emit PaperSubmitted(paperId, _ipfsHash, _reviewers);
    // Increment paperId
    paperId++;
  }

  function submitPaperScore(
    uint _paperScore,
    uint _paperId,
    string memory _comments) correctId(_paperId) submitted(_paperId) public onlyRole(DEFAULT_ADMIN_ROLE){
      papers[_paperId].paperScore = _paperScore;
      papers[_paperId].comments = _comments;
      papers[_paperId].paperScore = 1;
      emit ScoreSubmitted(_paperId, _paperScore, _comments);
  }

  function publishPaper(uint _paperId) reviewed(_paperId) public payable onlyRole(AUTHOR){
        papers[_paperId].paperScore = 2;
        _mint(msg.sender, _paperId, 1, "");
  }

  function revisionPaper(
    uint _paperId,    
    string memory _title,
    string memory _ipfsHash,
    uint _accessPrice,
    address[] memory _reviewers) reviewed(_paperId) public payable onlyRole(AUTHOR){
        
  } 


  // Define a function 'fetchPaperData' that fetches the data
  function fetchPaperData(uint _paperId) public view returns(
    uint id, 
    address author, 
    string memory title, 
    string memory ipfsHash,
    string memory comments, 
    uint accessPrice, 
    uint paperScore, 
    State paperState, 
    address[] memory reviewers)
  {
    id = papers[_paperId].paperId;
    author = papers[_paperId].author;
    title = papers[_paperId].title;
    ipfsHash = papers[_paperId].ipfsHash;
    comments = papers[_paperId].comments;
    accessPrice = papers[_paperId].accessPrice;
    paperScore = papers[_paperId].paperScore;
    paperState = papers[_paperId].paperState;
    reviewers = papers[_paperId].reviewers;

    return (
      id,
      author,
      title,
      ipfsHash,
      comments,
      accessPrice,
      paperScore,
      paperState,
      reviewers
    );
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
