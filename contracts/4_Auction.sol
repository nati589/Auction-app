// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

/**
 * @title Auction
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract Auction {
    address contractOwner;

    struct Product {
        uint id;
        string name;
        string desc;
        uint startingPrice;
        address payable owner;
        uint bidPrice;
        uint bidIncrement;
        address payable highestBidder;
        uint highestBid;
        bool status;
        uint256 endTime;
    }

    Product[] public products;
    mapping(address => uint) public refunds;

    modifier validateBid(uint id, uint amount) {
        Product storage myProduct = products[id];
        require(myProduct.status, "Auction is not active.");
        require(block.timestamp < myProduct.endTime, "Auction has ended.");
        require(myProduct.bidPrice <= amount, "Bid amount must be greater than price");
        _;
    }

    event AuctionCreated(uint id, string name, uint startingPrice, uint endTime);
    event BidPlaced(uint id, address bidder, uint amount);

    constructor () {
        contractOwner = msg.sender;
    }

    function createAuction(string memory _name, string memory _desc, uint _startingPrice, uint _bidIncrement, uint _duration) external {
        products.push(Product({
            id: products.length,
            name: _name,
            desc: _desc,
            startingPrice: _startingPrice,
            owner: payable(msg.sender),
            bidPrice: _startingPrice,
            bidIncrement: _bidIncrement,
            highestBidder: payable(address(0)),
            highestBid: 0,
            status: true,
            endTime: block.timestamp + _duration

        }));

        emit AuctionCreated(products.length - 1, _name, _startingPrice, block.timestamp + _duration);
        
    }

    function placeBid(uint _id) external payable validateBid(_id, msg.value) {
        // products[_id];
        Product storage product = products[_id];

        if (product.highestBidder != address(0)) {
            refunds[product.highestBidder] += product.highestBid;
        }
        product.highestBidder = payable(msg.sender);
        product.highestBid = msg.value;
        product.bidPrice = product.bidIncrement + msg.value;
        
        emit BidPlaced(_id, msg.sender, msg.value);
    }
    

}