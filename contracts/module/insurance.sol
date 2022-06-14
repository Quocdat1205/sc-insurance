// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";

contract Insurance is ChainlinkClient, ConfirmedOwner {
    using SafeMath for uint256;
    using Chainlink for Chainlink.Request;

    /*
     @chainlink
    **/
    uint256 public volume;
    bytes32 private jobId;
    uint256 private fee;
    // end chainlink

    /*
     @variable
    **/
    InsuranceStruct[] private insurances;
    address payable immutable pool;
    uint256 public totalInsurance = 0;

    constructor(address payable poolAddress) ConfirmedOwner(msg.sender) {
        setChainlinkToken(0xa36085F69e2889c224210F603D836748e7dC0088);
        setChainlinkOracle(0x74EcC8Bdeb76F2C6760eD2dc8A46ca5e581fA656);
        jobId = "ca98366cc7314957b8c012c72f05aeeb";
        fee = (1 * LINK_DIVISIBILITY) / 10;
        pool = poolAddress;
    }

    /*
     @modify
    **/
    modifier _onlyOwner(address _buyer) {
        require(_buyer == msg.sender, "Only owner");
        _;
    }
    modifier _validateDeposit(uint256 value) {
        require(value == msg.value, "Deposit not enough, please check again!");
        _;
    }
    modifier _onlyAdmin() {
        require(msg.sender == pool, "Only admin");
        _;
    }

    /*
     @event
    **/
    event EBuyInsurance(
        uint256 _idInsurance,
        address _buyer,
        uint256 deposit,
        uint256 _current_price,
        uint256 _liquidation,
        uint256 _expire
    );
    event RequestVolume(bytes32 indexed requestId, uint256 volume);
    event EUpdateStateInsurance();

    /*
     @Struct
    **/
    struct InsuranceStruct {
        uint256 _idInsurance;
        address owner;
        uint256 deposit;
        uint256 liquidation_price;
        uint256 current_price;
        string state;
        uint256 expire;
    }

    /*
     @function
    **/
    function requestVolumeData() public returns (bytes32 requestId) {
        Chainlink.Request memory req = buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfill.selector
        );

        req.add(
            "get",
            "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=ETH&tsyms=USD"
        );

        req.add("path", "RAW,ETH,USD,PRICE");

        int256 timesAmount = 10**18;
        req.addInt("times", timesAmount);

        return sendChainlinkRequest(req, fee);
    }

    function fulfill(bytes32 _requestId, uint256 _volume)
        public
        recordChainlinkFulfillment(_requestId)
    {
        emit RequestVolume(_requestId, _volume);
        volume = _volume;
    }

    function buyInsurance(
        address _buyer,
        uint256 _deposit,
        uint256 _current_price,
        uint256 _liquidation_price,
        uint256 _expire
    ) public payable _onlyOwner(_buyer) returns (bool) {
        require(
            _expire > block.timestamp + 7 days,
            "Sending time cannot be less than current time"
        );
        require(
            _deposit == msg.value,
            "Value does't enough, please check again!"
        );

        // transfer ETH deposit
        pool.transfer(msg.value);
        // end transfer

        InsuranceStruct memory newInsurance = InsuranceStruct(
            totalInsurance + 1,
            _buyer,
            _deposit,
            _liquidation_price,
            _current_price,
            "available",
            _expire
        );

        //emit event
        emit EBuyInsurance(
            totalInsurance + 1,
            _buyer,
            _deposit,
            _current_price,
            _liquidation_price,
            _expire
        );

        insurances.push(newInsurance);
        totalInsurance++;

        return true;
    }

    function getInsuraceForId(uint256 _idInsurance)
        public
        view
        returns (InsuranceStruct memory)
    {
        InsuranceStruct memory insurance = insurances[_idInsurance - 1];

        return insurance;
    }

    function getAllInsurance() public view returns (InsuranceStruct[] memory) {
        return insurances;
    }

    function updateStateInsurance(uint256 _idInsurance, string memory state)
        public
        _onlyAdmin
        returns (InsuranceStruct memory)
    {
        require(_idInsurance > 0, "Id can not be less then 0");

        if (
            compareString(insurances[_idInsurance].state, "expired") ||
            compareString(insurances[_idInsurance].state, "withDraw")
        ) {
            revert("State insurance can't not update, please check again!");
        }

        insurances[_idInsurance - 1].state = state;

        return insurances[_idInsurance - 1];
    }

    /* 
     @helper
    **/
    function compareNumber(uint256 a, uint256 b) private pure returns (bool) {
        return a == b;
    }

    function compareAddressWallet(address a, address b)
        private
        pure
        returns (bool)
    {
        return a == b;
    }

    function compareString(string memory a, string memory b)
        internal
        pure
        returns (bool)
    {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }
}
