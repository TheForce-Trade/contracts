pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

// SPDX-License-Identifier: SimPL-2.0

import "./interface/IBlockhashMgr.sol";

import "./lib/String.sol";
import "./lib/Util.sol";
import "./lib/UInteger.sol";

import "./shop/Shop.sol";

import "./Card.sol";
import "./ERC721Ex.sol";

// nftSign  packageType tokenAmount quantity    padding mintTime    index
// 1        31          64          16          40      40          64
// 255      224         160         144         104     64          0

contract Package is ERC721Ex {
    using String for string;
    using UInteger for uint256;

    event PackageOpened(address indexed owner, uint256 packageId, uint256[] cardIds);

    struct ShopInfo {
        uint256 id;
        bool enabled;
    }

    struct PackageInfo {
        uint256 blockNumber;
        Shop shop;
    }

    mapping(uint256 => PackageInfo) public packageInfos;

    uint256 public quantityMin = 1;
    uint256 public quantityMax = 50;

    mapping(address => ShopInfo) public shopInfos;
    uint256 public shopCount;

    constructor(string memory _name, string memory _symbol)
        ERC721(_name, _symbol)
    {}

    function setShop(address addr, bool enable) external CheckPermit("Config") {
        ShopInfo storage si = shopInfos[addr];

        if (si.id == 0) {
            si.id = ++shopCount;
        }

        si.enabled = enable;
    }

    function setQuantityMin(uint256 min) external CheckPermit("Config") {
        quantityMin = min;
    }

    function setQuantityMax(uint256 max) external CheckPermit("Config") {
        quantityMax = max;
    }

    function mint(
        address to,
        uint256 tokenAmount,
        uint256 quantity,
        uint256 padding,
        bool isOpen
    ) external {
        require(shopInfos[msg.sender].enabled, "shop not enabled");

        require(
            quantity >= quantityMin && quantity <= quantityMax,
            "invalid quantity"
        );

        uint256 shopId = shopInfos[msg.sender].id;
        uint256 initialAmount = tokenAmount.div(1e10);
        uint256 packageId =
            NFT_SIGN_BIT |
                (uint256(uint32(shopId)) << 224) |
                (uint256(uint64(initialAmount)) << 160) |
                (uint256(uint16(quantity)) << 144) |
                (uint256(uint40(padding)) << 104) |
                (block.timestamp << 64) |
                (uint64(totalSupply + 1));

        PackageInfo storage pi = packageInfos[packageId];

        pi.blockNumber = block.number + 1;
        // IBlockhashMgr(manager.members("blockhashMgr"))
        //     .request(pi.blockNumber);

        pi.shop = Shop(msg.sender);

        _mint(to, packageId);

        if(isOpen) {
            _addTokenTo(msg.sender, packageId);
            openInternal(packageId);
        }
    }

    function open(uint256 packageId) external {
        openInternal(packageId);
    }

    function openInternal(uint256 packageId) internal {
        require(
            msg.sender == tokenOwners[packageId],
            "you not own this package"
        );

        _burn(packageId);

        PackageInfo storage pi = packageInfos[packageId];

        // bytes32 bh = IBlockhashMgr(manager.members("blockhashMgr"))
        //     .getBlockhash(pi.blockNumber);
        bytes32 bh = bytes32(blockhash(pi.blockNumber));

        uint256[] memory cardIdPres =
            pi.shop.onOpenPackage(msg.sender, packageId, bh);

        Card card = Card(manager.members("card"));
        uint256 length = cardIdPres.length;

        for (uint256 i = 0; i != length; ++i) {
            card.mint(msg.sender, cardIdPres[i]);
        }

        emit PackageOpened(msg.sender, packageId, cardIdPres);

        delete packageInfos[packageId];
    }

    function batchOpen(uint256 packageId) external {
        require(
            msg.sender == tokenOwners[packageId],
            "you not own this package"
        );

        _burn(packageId);

        PackageInfo storage pi = packageInfos[packageId];

        // bytes32 bh = IBlockhashMgr(manager.members("blockhashMgr"))
        //     .getBlockhash(pi.blockNumber);
        bytes32 bh = bytes32(blockhash(pi.blockNumber + 1));

        uint256[] memory cardIdPres =
            pi.shop.onOpenPackage(msg.sender, packageId, bh);

        Card(manager.members("card")).batchMint(msg.sender, cardIdPres);

        delete packageInfos[packageId];
    }

    function batchOpens(uint256[] memory packageIds) external {
        uint256 length = packageIds.length;

        for (uint256 i = 0; i != length; ++i) {
            uint256 packageId = packageIds[i];
            require(
                msg.sender == tokenOwners[packageId],
                "you not own this package"
            );

            _burn(packageId);

            PackageInfo storage pi = packageInfos[packageId];

            // bytes32 bh = IBlockhashMgr(manager.members("blockhashMgr"))
            //     .getBlockhash(pi.blockNumber);
            bytes32 bh = bytes32(blockhash(pi.blockNumber + 1));

            uint256[] memory cardIdPres =
                pi.shop.onOpenPackage(msg.sender, packageId, bh);

            Card(manager.members("card")).batchMint(msg.sender, cardIdPres);

            delete packageInfos[packageId];
        }
    }

    function tokenURI(uint256 packageId)
        external
        view
        override
        returns (string memory)
    {
        PackageInfo storage pi = packageInfos[packageId];

        bytes memory bs = abi.encodePacked(packageId);

        uint256[] memory rarityWeights = pi.shop.getRarityWeights(packageId);

        uint256 length = rarityWeights.length;
        uint256 rarityWeightTotal = 0;
        for (uint256 i = 0; i != length; ++i) {
            rarityWeightTotal += rarityWeights[i];
        }

        uint256 weightMax = ~uint16(0);

        for (uint256 i = 0; i != length; ++i) {
            bs = abi.encodePacked(
                bs,
                uint16((rarityWeights[i] * weightMax) / rarityWeightTotal)
            );
        }

        return uriPrefix.concat("package/").concat(Util.base64Encode(bs));
    }
}
