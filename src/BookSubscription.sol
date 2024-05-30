// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
contract BookSubscription {
    struct Subscription {
        uint256 planId;
        uint256 expiryDate;
        uint256 booksAccessed;
    }

    struct Plan {
        uint256 price;
        uint256 bookLimit;
        uint256 duration;
    }

    // mapping for subscription
    mapping (address => Subscription) subscriptions;
    mapping (uint256 => Plan) plans;
    mapping (uint256 => string) books;

    // events
    event PlanCreated(
        uint256 planId, uint256 price, uint256 duration, uint256 bookLimit
    );
    event Subscribed(uint256 planId, uint256 expiration, address subscriber);
    event BookAccessed(address subscriber, uint256 bookId);

    address public owner;

    uint256 public nextPlanId;
    uint256 public nextBookId;

    // only modifier
    modifier onlyOwner {
        require(msg.sender==owner, "Only owner can call the function");
        _;
    }
    // active subscriber
    modifier hasActiveSubscription() {
        require(subscriptions[msg.sender].expiryDate>block.timestamp, "subscription has expired");
        _;
    }
    constructor() {
        owner = msg.sender;
    }

    function createPlan(uint256 _price, uint256 _bookLimit, uint256 _duration) external onlyOwner {
        plans[nextPlanId] = Plan(_price, _bookLimit,_duration);
        emit PlanCreated(nextPlanId, _price, _duration, _bookLimit);
        nextPlanId++;

    }
}