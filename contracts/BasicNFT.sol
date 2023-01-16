// SPDX-License-Identifier:MIT
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

error insufficientAmount();
error tokenSoldOut();
error withdrawalFailed();
error mintClosed();
error notAllowListed();

contract BasicNFT is ERC721URIStorage, Ownable {
    /**EVENTS
     * @dev 3illBaby
     *
     */

    event Transaction(address indexed seller, address indexed buyer);
    event Mints(address indexed minter);
    using Counters for Counters.Counter;

    /**
     * CONTRACT VARIABLES
     */

    string public TOKEN_URI;
    uint256 public mintFee;
    uint256 public allowListMintFee;
    uint256 public maxSupply;
    Counters.Counter private _tokenIdCounter;
    mapping(address => bool) public allowList;
    uint256 public totalSupply;
    bool private publicMint;
    bool private allowListminting;

    mapping(uint256 => address) public owners;

    constructor(
        string memory _tokenuri,
        uint256 _mintFee,
        uint256 _maxSupply,
        uint256 _allowFee
    ) ERC721("Thrill", "3ILL") {
        TOKEN_URI = _tokenuri;
        mintFee = _mintFee;
        maxSupply = _maxSupply;
        allowListMintFee = _allowFee;
        totalSupply = 0;
    }

    /**
     * MODIFIERS
     */

    modifier Mint() {
        if (msg.value < mintFee) {
            revert insufficientAmount();
        }
        _;
    }

    modifier allowListMintfee() {
        if (msg.value < allowListMintFee) {
            revert insufficientAmount();
        }
        _;
    }

    modifier Supply() {
        if (totalSupply >= maxSupply) {
            revert tokenSoldOut();
        }
        _;
    }

    modifier mintStatus() {
        if (publicMint == false) {
            revert mintClosed();
        }
        _;
    }

    modifier AmintingStatus() {
        if (allowListminting == false) {
            revert mintClosed();
        }
        _;
    }

    /**
     * @dev These are Write Fuctions hence cost some gas to execute 
     */

    //public minting 
    function mintNFT() public payable Mint Supply mintStatus {
        address Minter = msg.sender;
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(Minter, tokenId);
        _setTokenURI(tokenId, TOKEN_URI);
        owners[tokenId] = msg.sender;
        totalSupply++;

        emit Mints(Minter);
    }

    //Allow list minting
    function allowListMinting() public payable allowListMintfee AmintingStatus {
        require(allowList[msg.sender] != true, " Not in the Allow List");
        address Minter = msg.sender;
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(Minter, tokenId);
        _setTokenURI(tokenId, TOKEN_URI);
        owners[tokenId] = msg.sender;
        totalSupply++;

        emit Mints(Minter);
    }

    function transferNFT(
        address from,
        address to,
        uint256 tokenId
    ) public payable Mint {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "ERC721: caller is not token owner or approved"
        );
        _safeTransfer(from, to, tokenId, "");
        emit Transaction(from, to);
    }

    function withdrawal() public onlyOwner {
        uint256 amount = address(this).balance;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        if (!success) {
            revert withdrawalFailed();
        }
    }

    /**
     * @dev These are only owner functions hence can't be called by the public 
     */

    //open the public mint & AllowList minting 
    function openMint(bool _mint, bool _allowListMinting) external onlyOwner {
        publicMint = _mint;
        allowListminting = _allowListMinting;
    }

    //Add addresses to the allowList 
    function addToAllowList(address[] calldata _address) external onlyOwner {
        for (uint256 i = 0; i < _address.length; i++) {
            allowList[_address[i]] = true;
        }
    }

    /**
     * READ FUNCTIONS
     */

    function getTokenCounter() public view returns (Counters.Counter memory) {
        return _tokenIdCounter;
    }

    function getTokenURI() public view returns (string memory) {
        return TOKEN_URI;
    }

    function getMintFee() public view returns (uint256) {
        return mintFee;
    }

    function getMaxSupply() public view returns (uint256) {
        return maxSupply;
    }

    function getOwners(uint256 _index) public view returns (address) {
        return owners[_index];
    }
}
