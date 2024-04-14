// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {EigerSwap} from "../src/EigerSwap.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract EigerSwapSepoliaTest is Test {
    EigerSwap public eigerSwap;

    ERC20 public constant wEth =
        ERC20(0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9);

    ERC20 public constant usdcToken =
        ERC20(0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238);

    ERC20 public constant linkToken =
        ERC20(0x779877A7B0D9E8603169DdbD7836e478b4624789);

    address public constant factory =
        0x7E0987E5b3a30e3f2828572Bb659A548460a3003;

    address deployer = makeAddr("Deployer");
    address alice = makeAddr("Alice");
    address bob = makeAddr("Bob");

    function setUp() public {
        vm.createSelectFork("sepolia");
        eigerSwap = new EigerSwap(deployer, factory, address(wEth));
    }

    function testSwapEthForUsdc() public {
        deal(alice, 1 ether);
        vm.startPrank(alice);
        console.log(
            "balance usdc alice before swap %s",
            usdcToken.balanceOf(alice)
        );
        // test swap 0.5 ether for usdc
        uint256 amountOut = eigerSwap.swapEtherToToken{value: 0.0005 ether}(
            address(usdcToken),
            1
        );
        vm.stopPrank();
        uint256 balance = usdcToken.balanceOf(alice);
        vm.assertGt(balance, 1);
        vm.assertEq(balance, amountOut);
        console.log("balance usdc alice after swap %s", balance);
    }

    function testSwapEthForLink() public {
        deal(alice, 1 ether);
        vm.startPrank(alice);
        console.log(
            "balance linkToken alice before swap %s",
            linkToken.balanceOf(alice)
        );
        // test swap 0.5 ether for usdc
        uint256 amountOut = eigerSwap.swapEtherToToken{value: 0.0005 ether}(
            address(linkToken),
            1
        );
        vm.stopPrank();
        uint256 balance = linkToken.balanceOf(alice);
        vm.assertGt(balance, 1);
        vm.assertEq(balance, amountOut);
        console.log("balance linkToken alice after swap %s", balance);
    }

    function testFailedSwapEthForUsdc() public {
        deal(alice, 1 ether);
        vm.startPrank(alice);
        console.log(
            "balance usdc alice before swap %s",
            usdcToken.balanceOf(alice)
        );
        // testfailed if min out not respected
        uint256 tenThousand = 10_000 * 10 ** usdcToken.decimals();
        vm.expectRevert(EigerSwap.InsufficientOutputAmount.selector);
        eigerSwap.swapEtherToToken{value: 0.01 ether}(
            address(usdcToken),
            tenThousand
        );
        vm.stopPrank();
        uint256 balance = usdcToken.balanceOf(alice);
        vm.assertEq(balance, 0);
        console.log("balance usdc alice after swap %s", balance);
    }

    function testBlockSwap() public {
        vm.startPrank(deployer);
        eigerSwap.setFactory(address(0));
        vm.stopPrank();
        deal(alice, 1 ether);
        vm.startPrank(alice);
        console.log(
            "balance usdc alice before swap %s",
            usdcToken.balanceOf(alice)
        );
        vm.expectRevert(EigerSwap.NoFactoryDefined.selector);
        // test swap 0.5 ether for usdc
        uint256 amountOut = eigerSwap.swapEtherToToken{value: 0.5 ether}(
            address(usdcToken),
            1
        );
        vm.stopPrank();
        uint256 balance = usdcToken.balanceOf(alice);
        vm.assertEq(balance, 0);
    }

    function testNoPair() public {
        deal(alice, 1 ether);
        vm.startPrank(alice);
        vm.expectRevert(EigerSwap.NoPairFound.selector);
        // test swap 0.5 ether for usdc
        uint256 amountOut = eigerSwap.swapEtherToToken{value: 0.5 ether}(
            address(0),
            1
        );
        vm.stopPrank();
    }
}
