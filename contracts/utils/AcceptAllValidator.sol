// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.6.6;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorValidatorInterface.sol";

/**
 * @title The Accept All Validator contract
 * @notice This contract accepts all values submitted and should be considered a
 * 'skip validation' contract used by FluxAggregator
 */
contract AcceptAllValidator is AggregatorValidatorInterface {
    function validate(
        uint256 previousRoundId,
        int256 previousAnswer,
        uint256 currentRoundId,
        int256 currentAnswer
    ) external override returns (bool) {
        return true;
    }
}