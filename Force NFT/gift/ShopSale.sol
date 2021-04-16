pragma solidity ^0.7.0;

// SPDX-License-Identifier: SimPL-2.0

import "../interface/IEDC.sol";
import "../interface/IERC20.sol";
import "../interface/ISwapRouter.sol";

import "../lib/UInteger.sol";
import "../lib/String.sol";
import "../lib/Util.sol";

import "../Card.sol";
import "../shop/Shop.sol";

/// @title A facet of ShopSale that manages NFT.
/// @author Paul (Play@Mars)
/// @dev Contract ShopSale is aimed to provide on stock sales functionality...
contract ShopSale is Shop {
    using UInteger for uint256;
    using String for string;

    /// @dev The data structure of sale plan...
    struct SalePlan {
        uint256 maxForSale;
        uint256 startTime;
        uint256 endTime;
        uint256 unitPrice;
        uint256 sold;
    }

    /// artId -> SalePlan
    mapping(uint256 => SalePlan) public planMap;

    /// The ERC20 interface to pay the fee...
    IERC20 public money;

    /// The available start time.
    uint256 public startTime;

    /// The available end time.
    uint256 public endTime;

    constructor(
        address _money,
        uint256 _startTime,
        uint256 _endTime
    ) {
        money = IERC20(_money);
        startTime = _startTime;
        endTime = _endTime;
    }

    /// @dev Function buy is to buy the art with rarity and quantity.
    /// @param artId is the id to represent the art which is defined in setMaxSale function.
    /// @param rarity represents how rare the art is. This is a rank like "noraml", "magic", "rare", "unique", "legendary", etc...
    /// @param quantity is how many to buy.
    function buy(uint256 artId, uint256 rarity, uint256 quantity) external {
        uint256 _now = block.timestamp;
        require(planMap[artId].maxForSale > 0, "skin must be existed.");

        SalePlan storage plan = planMap[artId];

        require(_now >= plan.startTime, "it's hasn't started yet");
        require(_now <= plan.endTime, "it's over");

        planMap[artId].sold = planMap[artId].sold.add(quantity);

        require(plan.sold <= plan.maxForSale, "Shop: sold out");

        bool success =
        money.transferFrom(
            msg.sender,
            manager.members("cashier"),
            plan.unitPrice.mul(quantity)
        );
        require(success, "transfer money failed");

        uint256 amount = quantity;

        //artId << 16 & rarity
        uint256 padding = (uint16(artId) << 16) & (uint16(rarity));

        require(amount > 0, "too little token");

        Package package = Package(manager.members("package"));
        package.mint(
            msg.sender,
            amount,
            quantity,
            padding,
            true
        );
    }

    /// @dev Function setMaxSale is to set the sale plan by artId.
    /// @param artId is the id to represent the art which is defined in setMaxSale function.
    /// @param _startTime is the available start time.
    /// @param _endTime is the available end time.
    /// @param number is the quantity of the art.
    /// @param unitPrice is the unit price of the art.
    function setMaxSale(uint256 artId, uint256 _startTime, uint256 _endTime, uint256 number, uint256 unitPrice) external CheckPermit("Config") {
        planMap[artId].maxForSale = number;
        planMap[artId].startTime = _startTime;
        planMap[artId].endTime = _endTime;
        planMap[artId].sold = 0;
        planMap[artId].unitPrice = unitPrice;
    }

    /// @dev Function getSold is to get how many art has been sold.
    /// @param artId is the id to represent the art which is defined in setMaxSale function.
    function getSold(uint256 artId) external view returns (uint256) {
        require(planMap[artId].maxForSale > 0, "skin must be existed.");
        return planMap[artId].sold;
    }

    /// @dev Function onOpenPackage is the callback function invoked when the package is opened.
    /// @param packageId is the id of the opening package.
    function onOpenPackage(
        address,
        uint256 packageId,
        bytes32
    ) external pure override returns (uint256[] memory) {
        uint256 cardType = uint32(packageId >> 224);

        //padding.size == 40, but only use 32 for skin(16) and rarity(16).
        uint256 skinAndRarity = uint32(packageId >> 104);

        uint256 initialAmount = uint64(packageId >> 160);
        uint256 quantity = uint16(packageId >> 144);

        uint256[] memory cardIdPres = new uint256[](quantity);

        for (uint256 i = 0; i != quantity; ++i) {
            cardIdPres[i] =
            (cardType << 224) |
            (skinAndRarity << 192) |
            (initialAmount << 128);
        }

        return cardIdPres;
    }

    /// @dev Function getRarityWeights is inherit from Shop.
    function getRarityWeights(uint256) external pure override returns (uint256[] memory) {
        return new uint256[](0);
    }
}
