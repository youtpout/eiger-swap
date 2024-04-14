// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {EigerSwap} from "../src/EigerSwap.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract EigerSwapTest is Test {
    EigerSwap public eigerSwap;

    ERC20 public constant wEth =
        ERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    ERC20 public constant daiToken =
        ERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);

    address public constant factory =
        0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;

    address deployer = makeAddr("Deployer");
    address alice = makeAddr("Alice");
    address bob = makeAddr("Bob");

    function setUp() public {
        vm.createSelectFork("mainnet");
        eigerSwap = new EigerSwap(deployer, factory, address(wEth));
    }

    function testSwapEthForDai() public {
        deal(alice, 1 ether);
        vm.startPrank(alice);
        console.log(
            "balance dai alice before swap %s",
            daiToken.balanceOf(alice)
        );
        // test swap 0.5 ether for dai
        uint256 amountOut = eigerSwap.swapEtherToToken{value: 0.5 ether}(
            address(daiToken),
            1
        );
        vm.stopPrank();
        uint256 balance = daiToken.balanceOf(alice);
        vm.assertGt(balance, 1);
        vm.assertEq(balance, amountOut);
        console.log("balance dai alice after swap %s", balance);
    }

    function testFailedSwapEthForDai() public {
        deal(alice, 1 ether);
        vm.startPrank(alice);
        console.log(
            "balance dai alice before swap %s",
            daiToken.balanceOf(alice)
        );
        // testfailed if min out not respected
        uint256 tenThousand = 10_000 * 10 ** daiToken.decimals();
        vm.expectRevert(EigerSwap.InsufficientOutputAmount.selector);
        eigerSwap.swapEtherToToken{value: 0.01 ether}(
            address(daiToken),
            tenThousand
        );
        vm.stopPrank();
        uint256 balance = daiToken.balanceOf(alice);
        vm.assertEq(balance, 0);
        console.log("balance dai alice after swap %s", balance);
    }

    function testBlockSwap() public {
        vm.startPrank(deployer);
        eigerSwap.setFactory(address(0));
        vm.stopPrank();
        deal(alice, 1 ether);
        vm.startPrank(alice);
        console.log(
            "balance dai alice before swap %s",
            daiToken.balanceOf(alice)
        );
        vm.expectRevert(EigerSwap.NoFactoryDefined.selector);
        // test swap 0.5 ether for dai
        uint256 amountOut = eigerSwap.swapEtherToToken{value: 0.5 ether}(
            address(daiToken),
            1
        );
        vm.stopPrank();
        uint256 balance = daiToken.balanceOf(alice);
        vm.assertEq(balance, 0);
    }

    function testNoPair() public {
        deal(alice, 1 ether);
        vm.startPrank(alice);
        vm.expectRevert(EigerSwap.NoPairFound.selector);
        // test swap 0.5 ether for dai
        uint256 amountOut = eigerSwap.swapEtherToToken{value: 0.5 ether}(
            address(0),
            1
        );
        vm.stopPrank();
    }
}
