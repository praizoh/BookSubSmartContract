// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {BookSubscription} from "../src/BookSubscription.sol";

contract BookSubscriptionTest is Test {
    BookSubscription public bookSubscription;
    address owner = address(1);
    address user = address(2);

    function setUp() public {
        bookSubscription = new BookSubscription();
    }

    function testCreatePlan() public {
        bookSubscription.createPlan(1 ether, 5, 10 days);
        assertEq(bookSubscription.nextPlanId(), 1);
    }

    function testFailedCreatePlan() public {
        vm.prank(user);
        bookSubscription.createPlan(1 ether, 5, 10 days);
        assertEq(bookSubscription.nextPlanId(), 1);
    }
}