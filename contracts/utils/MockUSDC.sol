// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockUSDC is ERC20("Mock USDC", "USDC") {
    uint256 constant CAP = 1_000_000 ether;

    constructor() {
        _mint(_msgSender(), CAP);
    }
}
