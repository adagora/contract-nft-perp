// SPDX-License-Identifier: MIT
pragma solidity 0.6.6;

import "@chainlink/contracts/src/v0.6/FluxAggregator.sol";

contract CustomFluxAggregator is FluxAggregator {
    constructor(
        address _link,
        uint128 _paymentAmount,
        uint32 _timeout,
        address _validator,
        int256 _minSubmissionValue,
        int256 _maxSubmissionValue,
        uint8 _decimals,
        string memory _description
    )
        public
        FluxAggregator(
            _link,
            _paymentAmount,
            _timeout,
            _validator,
            _minSubmissionValue,
            _maxSubmissionValue,
            _decimals,
            _description
        )
    {}
}
