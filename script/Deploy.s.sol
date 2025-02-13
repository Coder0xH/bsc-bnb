// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/BscOrder.sol";

contract DeployScript is Script {
    function setUp() public {}

    function run() public {
        // Retrieve private key from environment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Get configuration from environment
        address receiver = vm.envAddress("RECEIVER_ADDRESS");
        address owner = vm.envAddress("OWNER_ADDRESS");

        // Start broadcasting
        vm.startBroadcast(deployerPrivateKey);

        // Deploy contract
        BscOrder order = new BscOrder(receiver, owner);

        console.log("BscOrder deployed to:", address(order));
        console.log("Receiver:", receiver);
        console.log("Owner:", owner);

        vm.stopBroadcast();
    }
}
