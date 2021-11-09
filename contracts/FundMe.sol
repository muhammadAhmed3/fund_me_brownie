// SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;
import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";
// interface AggregatorV3Interface {
//   function decimals() external view returns (uint8);

//   function description() external view returns (string memory);

//   function version() external view returns (uint256);

//   // getRoundData and latestRoundData should both raise "No data present"
//   // if they do not have data to report, instead of returning unset values
//   // which could be misinterpreted as actual reported values.
//   function getRoundData(uint80 _roundId)
//     external
//     view
//     returns (
//       uint80 roundId,
//       int256 answer,
//       uint256 startedAt,
//       uint256 updatedAt,
//       uint80 answeredInRound
//     );

//   function latestRoundData()
//     external
//     view
//     returns (
//       uint80 roundId,
//       int256 answer,
//       uint256 startedAt,
//       uint256 updatedAt,
//       uint80 answeredInRound
//     );
// }



contract FundMe{
    
    // In order to use the safe math link we are going to use the below command
    using SafeMathChainlink for uint256;
    address public owner;
    address [] public funders ;
    AggregatorV3Interface public priceFeed;
    constructor(address _priceFeed) public {
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner =msg.sender;
    }
    
    mapping (address => uint256) public addressToAmountFunded;
    function fund() public payable{
        uint256 mininumUSD = 50 * 10 ** 18; // setting $50 minimum we are multiply by 10 **18
            // we can use the if statement for putting the condition or the require statement

        require(getConversionRate(msg.value) >= mininumUSD , "You need to spend more ETH!");

        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    } 
    function getVersion() public view returns(uint256) {
        // AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        return priceFeed.version();
    }
    function getPrice() public view returns(uint256){
        // AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
    (,int256 answer,,,) = priceFeed.latestRoundData();
    //3979209845250000000000
    return uint256(answer * 10000000000);
    }
    // 1000000000
    
    function getConversionRate(uint256 ethAmount) public view returns(uint256){
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
        return ethAmountInUsd;
    }
    
    function getEntranceFee() public view returns(uint256){
        // minimum USD
        uint256 minimumUSD = 50 * 10**18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10**18;
        return (minimumUSD * precision) / price;

    }

    // modifier is the keyword which we used when only with the admin
    
    modifier onlyOwner{
        
        require(msg.sender == owner); // it means this is the owner of the contract.
        _;   //
    }
    
    
    // function to withdraw the funds
    //the onlyOwner function first runs and where it gets the _ then it back to the function which is called.
    event DataStored(address val);

    function withdraw() public onlyOwner payable{
        msg.sender.transfer(address(this).balance);
        
        // when we are going to withdraw all the money which we get from all the funders and then make that address value =0
        for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
            emit DataStored(funder);

        }
        // resetting the funders list
        funders = new address[](0);
    }
    
    
    // what is the rate for the ETH -> USD called the Oracle Problem
    // Chinalink is the basic solution for that 
    // There is an issue with the overflow in the 
    
}