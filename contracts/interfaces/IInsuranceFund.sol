// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Decimal} from "../utils/Decimal.sol";
import {IAmm} from "./IAmm.sol";

interface IInsuranceFund {
    function withdraw(
        IERC20 _quoteToken,
        Decimal.decimal calldata _amount
    ) external;

    function isExistedAmm(IAmm _amm) external view returns (bool);

    function getAllAmms() external view returns (IAmm[] memory);
}
