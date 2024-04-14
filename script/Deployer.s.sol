// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {EigerSwap} from "../src/EigerSwap.sol";

contract DeployerScript is Script {
    uint256 private deployerPrivateKey;

    function setUp() public {}

    function run() public {
        // sepolia address
        address wEth = 0xfFf9976782d46CC05630D1f6eBAb18b2324d6B14;
        address factory = 0xB7f907f7A9eBC822a80BD25E224be42Ce0A698A0;

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
