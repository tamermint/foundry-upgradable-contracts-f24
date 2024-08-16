// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {UpgradeBox} from "../script/UpgradeBox.s.sol";
import {DeployBox} from "../script/DeployBox.s.sol";
import {BoxV1} from "../src/BoxV1.sol";
import {BoxV2} from "../src/BoxV2.sol";

contract UpgradeAndDeployTest is Test {
    DeployBox public deployer;
    UpgradeBox public upgrader;
    // BoxV1 public boxV1; Deployer will return the proxy address of BoxV1 so better to use address proxy for declaring

    address owner = makeAddr("owner");
    address proxy;

    function setUp() public {
        deployer = new DeployBox();
        upgrader = new UpgradeBox();
        proxy = deployer.run(); //points to boxV1
    }

    function testProxyStartsAsBoxV1() public {
        vm.expectRevert();
        BoxV2(proxy).setNumber(7);
    }

    function testUpgrades() public {
        BoxV2 newBox = new BoxV2();
        upgrader.upgradeBox(proxy, address(newBox));

        uint256 expectedValue = 2;
        assertEq(expectedValue, BoxV2(proxy).getVersion());

        BoxV2(proxy).setNumber(7);
        assertEq(7, BoxV2(proxy).getNumber());
    }
}
