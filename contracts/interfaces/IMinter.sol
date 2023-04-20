// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Decimal} from "../utils/Decimal.sol";

interface IMinter {
    function mintReward() external;

    function mintForLoss(Decimal.decimal memory _amount) external;

    function getPerpToken() external view returns (IERC20);
}
