// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

import {SafeMath} from "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {IPriceFeed} from "./interfaces/IPriceFeed.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {Decimal} from "./utils/Decimal.sol";
import {BlockContext} from "./utils/BlockContext.sol";

contract ChainlinkPriceFeed is IPriceFeed, OwnableUpgradeable, BlockContext {
    using SafeMath for uint256;

    uint256 private constant TOKEN_DIGIT = 10 ** 18;

    //**********************************************************//
    //    The below state variables can not change the order    //
    //**********************************************************//

    // key by currency symbol, eg ETH
    mapping(bytes32 => AggregatorV3Interface) public priceFeedMap;
    bytes32[] public priceFeedKeys;
    mapping(bytes32 => uint8) public priceFeedDecimalMap;
    //**********************************************************//
    //    The above state variables can not change the order    //
    //**********************************************************//

    //◥◤◥◤◥◤◥◤◥◤◥◤◥◤◥◤ add state variables below ◥◤◥◤◥◤◥◤◥◤◥◤◥◤◥◤//

    //◢◣◢◣◢◣◢◣◢◣◢◣◢◣◢◣ add state variables above ◢◣◢◣◢◣◢◣◢◣◢◣◢◣◢◣//
    uint256[50] private __gap;

    //
    // FUNCTIONS
    //
    function initialize() public initializer {
        __Ownable_init();
    }

    function addAggregator(
        bytes32 _priceFeedKey,
        address _aggregator
    ) external onlyOwner {
        requireNonEmptyAddress(_aggregator);
        if (address(priceFeedMap[_priceFeedKey]) == address(0)) {
            priceFeedKeys.push(_priceFeedKey);
        }
        priceFeedMap[_priceFeedKey] = AggregatorV3Interface(_aggregator);
        priceFeedDecimalMap[_priceFeedKey] = AggregatorV3Interface(_aggregator)
            .decimals();
    }

    function removeAggregator(bytes32 _priceFeedKey) external onlyOwner {
        requireNonEmptyAddress(address(getAggregator(_priceFeedKey)));
        delete priceFeedMap[_priceFeedKey];
        delete priceFeedDecimalMap[_priceFeedKey];

        uint256 length = priceFeedKeys.length;
        for (uint256 i; i < length; i++) {
            if (priceFeedKeys[i] == _priceFeedKey) {
                // if the removal item is the last one, just `pop`
                if (i != length - 1) {
                    priceFeedKeys[i] = priceFeedKeys[length - 1];
                }
                priceFeedKeys.pop();
                break;
            }
        }
    }

    //
    // VIEW FUNCTIONS
    //

    function getAggregator(
        bytes32 _priceFeedKey
    ) public view returns (AggregatorV3Interface) {
        return priceFeedMap[_priceFeedKey];
    }

    //
    // INTERFACE IMPLEMENTATION
    //

    function getPrice(
        bytes32 _priceFeedKey
    ) external view override returns (uint256) {
        AggregatorV3Interface aggregator = getAggregator(_priceFeedKey);
        requireNonEmptyAddress(address(aggregator));

        (, uint256 latestPrice, ) = getLatestRoundData(aggregator);
        return formatDecimals(latestPrice, priceFeedDecimalMap[_priceFeedKey]);
    }

    //
    // INTERNAL VIEW FUNCTIONS
    //

    function getLatestRoundData(
        AggregatorV3Interface _aggregator
    ) internal view returns (uint80, uint256 finalPrice, uint256) {
        (
            uint80 round,
            int256 latestPrice,
            ,
            uint256 latestTimestamp,

        ) = _aggregator.latestRoundData();
        finalPrice = uint256(latestPrice);
        if (latestPrice < 0) {
            requireEnoughHistory(round);
            (round, finalPrice, latestTimestamp) = getRoundData(
                _aggregator,
                round - 1
            );
        }
        return (round, finalPrice, latestTimestamp);
    }

    function getRoundData(
        AggregatorV3Interface _aggregator,
        uint80 _round
    ) internal view returns (uint80, uint256, uint256) {
        (
            uint80 round,
            int256 latestPrice,
            ,
            uint256 latestTimestamp,

        ) = _aggregator.getRoundData(_round);
        while (latestPrice < 0) {
            requireEnoughHistory(round);
            round = round - 1;
            (, latestPrice, , latestTimestamp, ) = _aggregator.getRoundData(
                round
            );
        }
        return (round, uint256(latestPrice), latestTimestamp);
    }

    function formatDecimals(
        uint256 _price,
        uint8 _decimals
    ) internal pure returns (uint256) {
        return _price.mul(TOKEN_DIGIT).div(10 ** uint256(_decimals));
    }

    //
    // REQUIRE FUNCTIONS
    //

    function requireNonEmptyAddress(address _addr) internal pure {
        require(_addr != address(0), "empty address");
    }

    function requireEnoughHistory(uint80 _round) internal pure {
        require(_round > 0, "Not enough history");
    }

    function requirePositivePrice(int256 _price) internal pure {
        // a negative price should be reverted to prevent an extremely large/small premiumFraction
        require(_price > 0, "Negative price");
    }
}
