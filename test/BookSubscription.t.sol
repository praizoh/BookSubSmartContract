// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {BookSubscription} from "../src/BookSubscription.sol";

contract BookSubscriptionTest is Test {
    BookSubscription public bookSubscription;
    address owner = address(1);
    address user = address(2);
    uint256 amountToSend = 1 ether; // 1 Ether

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
    function testCreateBook() public {
        bookSubscription.createBook("Blockchain in 2 hours", "903-09");
        assertEq(bookSubscription.nextBookId(), 1);
    }
    function testFailedCreateBook() public {
        vm.prank(user);
        bookSubscription.createBook("Blockchain in 2 hours", "903-09");
        assertEq(bookSubscription.nextBookId(), 1);
    }

    function testCreateSubscription() public {
        
        uint256 balanceBefore = address(bookSubscription).balance;
        bookSubscription.createPlan(1 ether, 5, 10 days);
        vm.prank(user);
        vm.deal(user, 2 ether);
        bookSubscription.createSubscription{value: amountToSend}(
            0
        );
        uint256 balanceAfter = address(bookSubscription).balance;
        assertGt(bookSubscription.getSubscription(user).expiryDate,block.timestamp);
        assertEq(balanceAfter - balanceBefore, 1 ether, "expect increase of 1 ether");
    }

    function testFailedCreateSubscriptionInvalidAmount() public {
        bookSubscription.createPlan(1 ether, 5, 10 days);
        vm.prank(user);
        vm.deal(user, 2 ether);
        bookSubscription.createSubscription{value: 1 wei}(
            0
        );
    }

    function testFailedCreateSubscriptionPlanNotExist() public {
        vm.prank(user);
        vm.deal(user, 2 ether);
        bookSubscription.createSubscription{value: 1 ether}(
            0
        );
    }

    function testFailedCreateSubscriptionHasOngoignSubscription() public {
        bookSubscription.createPlan(1 ether, 5, 10 days);
        bookSubscription.createPlan(1 ether, 5, 10 days);
        vm.prank(user);
        vm.deal(user, 2 ether);
        assertEq(bookSubscription.getSubscription(user).expiryDate,0);
        vm.prank(user);
        vm.deal(user, 2 ether);
        bookSubscription.createSubscription{value: 1 ether}(
            0
        );
        assertGt(bookSubscription.getSubscription(user).expiryDate,0);
        vm.prank(user);
        vm.deal(user, 2 ether);
        bookSubscription.createSubscription{value: 1 ether}(
            1
        );
    }

    function testAccessBook() public {
        bookSubscription.createPlan(1 ether, 1, 10 days);
        bookSubscription.createBook("What children want", "874-09j");
        vm.startPrank(user);
        vm.deal(user, 2 ether);
        bookSubscription.createSubscription{value: 1 ether}(
            0
        );
        bookSubscription.accessBook(0);
        assertGt(bookSubscription.getSubscription(user).booksAccessed, 0);
        vm.stopPrank();
    }

    function testFailedAccessBookLimitExceed() public {
        bookSubscription.createPlan(1 ether, 1, 10 days);
        bookSubscription.createBook("What children want", "874-09j");
        bookSubscription.createBook("What children want pt2", "874-09j");
        vm.startPrank(user);
        vm.deal(user, 2 ether);
        bookSubscription.createSubscription{value: 1 ether}(
            0
        );
        bookSubscription.accessBook(0);
        bookSubscription.accessBook(1);
        assertGt(bookSubscription.getSubscription(user).booksAccessed, 0);
        vm.stopPrank();
    }

    function testFailedAccessBookTwice() public {
        bookSubscription.createPlan(1 ether, 2, 10 days);
        bookSubscription.createBook("What children want", "874-09j");
        vm.startPrank(user);
        vm.deal(user, 2 ether);
        bookSubscription.createSubscription{value: 1 ether}(
            0
        );
        bookSubscription.accessBook(0);
        bookSubscription.accessBook(0);
        assertGt(bookSubscription.getSubscription(user).booksAccessed, 0);
        vm.stopPrank();
    }
}