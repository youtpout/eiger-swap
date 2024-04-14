// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {EigerSwap} from "../src/EigerSwap.sol";

contract DeployerScript is Script {
    uint256 private deployerPrivateKey;

    function setUp() public {}

    function run() public {
        // sepolia address
        address wEth = 0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9;
        address factory = 0x7E0987E5b3a30e3f2828572Bb659A548460a3003;

        deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address deployer = vm.addr(deployerPrivateKey);
        EigerSwap eigerSwap = new EigerSwap(deployer, factory, wEth);
        console.logString(
            string.concat(
                "EigerSwap deployed at: ",
                vm.toString(address(eigerSwap))
            )
        );
        vm.stopBroadcast();
    }
}
