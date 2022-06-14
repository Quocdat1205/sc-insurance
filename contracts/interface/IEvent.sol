// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IEvent {
    event EBuyInsurance(address _buyer, uint256 _price, uint256 _liquidation, uint256 _expired, uint256 _idInsurance);

    event ETransferInsurance(address _buyer);

    event EUpdateStatusInsurance(string status);
}