// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IInsurance {
    function buyInsurance(
        address _owner,
        uint256 deposit,
        uint256 _current_price,
        uint256 _liquidation_price,
        uint256 _expired
    ) external; // status default: available

    function updateStatusInsurance(uint256 _idInsurance, string memory status)
        external;

    function transferOwner(uint256 _idInsurance, address _buyer) external;
}
