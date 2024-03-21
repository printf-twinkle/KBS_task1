// SPDX-License-Identifier: MIT
pragma solidity <=0.8.24;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";

contract FundMe {
    using PriceConverter for uint256;

    address[] public funders;
    address public owner;
    uint256 public constant MINIMUM_USD = 50 * 10 ** 18;
    
    constructor() {
        owner = msg.sender;
    }

    function fund() public payable {
        require(msg.value.getConversionRate() >= MINIMUM_USD, "You need to spend more ETH!");
        require(!isFunder(msg.sender), "Address has already funded");
        
        funders.push(msg.sender);
    }

    function isFunder(address _address) internal view returns (bool) {
        for (uint256 i = 0; i < funders.length; i++) {
            if (funders[i] == _address) {
                return true;
            }
        }
        return false;
    }
    
    function getVersion() public view returns (uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        return priceFeed.version();
    }
    
    modifier onlyOwner {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }
    
    function withdraw() public onlyOwner {
        delete funders;
        payable(msg.sender).transfer(address(this).balance);
    }

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }
}

