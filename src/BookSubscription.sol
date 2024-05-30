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

    struct Book {
        string name;
        string isbn;
    }

    // mapping for subscription
    mapping (address => Subscription) subscriptions;
    mapping (uint256 => Plan) plans;
    mapping (uint256 => Book) books;
    mapping(address => mapping(uint256 => bool)) public userBookAccess;

    // events
    event PlanCreated(
        uint256 planId, uint256 price, uint256 duration, uint256 bookLimit
    );
    event Subscribed(uint256 planId, uint256 expiration, address subscriber);
    event BookAccessed(address subscriber, uint256 bookId);
    event BookCreated(string name, string isbn);

    address public owner;

    uint256 public nextPlanId;
    uint256 public nextBookId;

    // modifiers
    modifier onlyOwner {
        require(msg.sender==owner, "Only owner can call the function");
        _;
    }
    // active subscriber
    modifier hasActiveSubscription() {
        require(subscriptions[msg.sender].expiryDate>block.timestamp, "subscription has expired");
        _;
    }
    modifier hasOngoingSubscription() {
        require(subscriptions[msg.sender].expiryDate!=0, "you have an ongoing subscription");
        _;
    }
    modifier isValidAmount(uint256 _price) {
        require(msg.value==_price, "Invalid amount");
        _;
    }
    modifier validPlanAmount(uint256 _price) {
        require(_price>0, "Invalid amount");
        _;
    }
    modifier planExists(uint256 _planId) { // assumes price for plan cannot be zero. Solidity returns default value for keys not found which is 0 for price
        require(plans[_planId].price>0, "Plan does not exist");
        _;
    }
    modifier bookExists(uint256 _bookId) { 
        require(keccak256(abi.encodePacked(books[_bookId].name)) != keccak256(abi.encodePacked("")), "Book does not exist");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createPlan(uint256 _price, uint256 _bookLimit, uint256 _duration) external onlyOwner validPlanAmount(_price) {
        plans[nextPlanId] = Plan(_price, _bookLimit,_duration);
        emit PlanCreated(nextPlanId, _price, _duration, _bookLimit);
        nextPlanId++;

    }

    function createBook(string memory _name, string memory _isbn) external onlyOwner {
        books[nextBookId] = Book(_name, _isbn);
        emit BookCreated(_name, _isbn);
        nextBookId++;
    }

    function createSubscription(uint256 _planId) external payable planExists(_planId) isValidAmount(plans[_planId].price) {

        // Check if the user already has a subscription
        Subscription storage subscription = subscriptions[msg.sender];
        // If the user has an expired subscription, delete it
        if (subscription.expiryDate > 0 && subscription.expiryDate <= block.timestamp) {
            delete subscriptions[msg.sender];
        }

        require(subscription.expiryDate==0, "you have an ongoing subscription");

        Plan memory plan = plans[_planId];
        uint256 expiration =  block.timestamp + plan.duration;
        subscriptions[msg.sender] = Subscription(
            _planId, 
           expiration,
            0
        );
        emit Subscribed(_planId, expiration, msg.sender);
    }

    function accessBook(uint256 _bookId) external bookExists(_bookId) hasActiveSubscription {
        Subscription storage subscription = subscriptions[msg.sender];
        Plan memory plan = plans[subscription.planId];
        require(subscription.booksAccessed < plan.bookLimit, "Book limit reached for current plan");
        require(!userBookAccess[msg.sender][_bookId], "Book already accessed");

        userBookAccess[msg.sender][_bookId] = true;
        subscription.booksAccessed++;

        emit BookAccessed(msg.sender, _bookId);
    }

    function getSubscription(address _subscriber) external view returns (Subscription memory) {
        return subscriptions[_subscriber];
    }

    function getPlan(uint256 _planId) external view returns (Plan memory) {
        return plans[_planId];
    }

    function getBook(uint256 _bookId) external view returns (Book memory) {
        return books[_bookId];
    }
}