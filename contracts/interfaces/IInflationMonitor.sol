// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

import {Decimal} from "../utils/Decimal.sol";

interface IInflationMonitor {
    function isOverMintThreshold() external view returns (bool);

    function appendMintedTokenHistory(
        Decimal.decimal calldata _amount
    ) external;
}
