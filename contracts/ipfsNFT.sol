// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @dev ERRORS
 *
 */
error rangeoutofBounds();
error insufficientFunds();
error withdrawalUnsuccesful();

contract ipfsNFT is VRFConsumerBaseV2, ERC721URIStorage, Ownable {
    event nftRequested(uint256 indexed requestId, address indexed requester);
    event nftMinted(Species nftSpecies, address indexed minter);

    enum Species {
        cyberNFT,
        cyberReaper,
        skullFucked
    }

    /**
     * @dev CHAINLINK REQUEST VARIABLES
     */
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    uint64 private immutable i_subscriptionId;
    bytes32 private immutable i_gasLane;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;
    uint32 private immutable i_callbackGasLimit;

    /**
     * @dev NFT VARIABLES
     */
    uint256 public s_tokenCounter;
    uint256 public MAX_CHANCE_VALUE;
    string[3] internal s_SpeciestokenURI;
    uint256 internal s_mintFee;

    //VFF Helpers
    mapping(uint256 => address) public s_requestIdToSender;

    /**
     * @dev CONTRACT MODIFIERS
     */
    modifier MintFee() {
        if (msg.value < s_mintFee) {
            revert insufficientFunds();
        }
        _;
    }

    constructor(
        address vrfCoordinatorV2,
        uint64 subscriptionId,
        bytes32 gasLane,
        uint32 callbackGasLimit,
        string[3] memory _speciesTokenURI,
        uint256 mintFee
    ) VRFConsumerBaseV2(vrfCoordinatorV2) ERC721("Thrill", "3ILL") {
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_subscriptionId = subscriptionId;
        i_gasLane = gasLane;
        i_callbackGasLimit = callbackGasLimit;
        s_SpeciestokenURI = _speciesTokenURI;
        s_mintFee = mintFee;
    }

    function requestNFT() public payable MintFee returns (uint256 requestId) {
        requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );
        s_requestIdToSender[requestId] = msg.sender;
        emit nftRequested(requestId, msg.sender);
    }

    function withdraw() public onlyOwner {
        uint256 amount = address(this).balance;
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        if (!success) {
            revert withdrawalUnsuccesful();
        }
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {
        address nftOwner = s_requestIdToSender[requestId];
        uint256 newTokenId = s_tokenCounter;

        uint256 moddedRng = randomWords[0] % MAX_CHANCE_VALUE;
        Species nftSpecies = getSpeciesModdedRng(moddedRng);
        _safeMint(nftOwner, newTokenId);
        _setTokenURI(newTokenId, s_SpeciestokenURI[uint256(nftSpecies)]);
        emit nftMinted(nftSpecies, nftOwner);
    }

    function getSpeciesModdedRng(
        uint256 moddedRng
    ) public view returns (Species) {
        uint256 CumulativeSum = 0;
        uint256[3] memory chanceArray = getChanceArray();

        for (uint256 i = 0; i < chanceArray.length; i++) {
            if (
                moddedRng >= CumulativeSum &&
                moddedRng < CumulativeSum + chanceArray[i]
            ) {
                return Species(i);
            }
            CumulativeSum += chanceArray[i];
        }

        revert rangeoutofBounds();
    }

    /**
     * @dev The chance Array is used to set the rarity
     */

    function getChanceArray() public view returns (uint256[3] memory) {
        return [10, 30, MAX_CHANCE_VALUE];
    }

    function getMintFee() public view returns (uint256) {
        return s_mintFee;
    }

    function getTokenURIS(uint256 _index) public view returns (string memory) {
        return s_SpeciestokenURI[_index];
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }
}
