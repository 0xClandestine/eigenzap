// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/EigenZap.sol";

contract EigenZapTest is Test {
    StrategyManager constant manager =
        StrategyManager(0x858646372CC42E1A627fcE94aa7A7033e7CF075A);
    stETH constant stEth = stETH(0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84);
    rETH constant rEth = rETH(0xae78736Cd615f374D3085123A210448E74Fc6393);
    address constant lidoStrategy = 0x93c4b944D05dfe6df7645A86cd2206016c51564D;
    address constant rocketStrategy = 0x1BeE69b7dFFfA4E2d53C2a2Df135C388AD25dCD2;
    RocketDepositPool constant rocketDepositPool =
        RocketDepositPool(0xDD3f50F8A6CafbE9b31a427582963f465E745AF8);
    RocketDAOProtocolSettingsDeposit constant rocketSettingsDeposit =
    RocketDAOProtocolSettingsDeposit(0xac2245BE4C2C1E9752499Bcd34861B761d62fC27);

    uint256 key;
    address signer;

    EigenZap zap;

    function setUp() public {
        vm.selectFork(vm.createFork("https://eth.llamarpc.com", 17480446));

        zap = new EigenZap(
            manager,
            stEth,
            rEth,
            lidoStrategy,
            rocketStrategy,
            rocketDepositPool,
            rocketSettingsDeposit
        );

        key = 420;
        signer = vm.addr(key);

        vm.label(address(zap), "zap");
        vm.label(vm.addr(420), "signer");
        vm.label(address(this), "test");
        vm.label(address(manager), "manager");
        vm.label(address(stEth), "stEth");
        vm.label(address(rEth), "rEth");
        vm.label(lidoStrategy, "lidoStrategy");
        vm.label(rocketStrategy, "rocketStrategy");
        vm.label(address(rocketDepositPool), "rocketDepositPool");
        vm.label(address(rocketSettingsDeposit), "rocketSettingsDeposit");
    }

    function testZapIntoLido() public {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            key,
            zap.computeDigest(
                address(lidoStrategy),
                address(stEth),
                1 ether,
                0,
                block.timestamp
            )
        );

        vm.deal(signer, 1 ether);
        vm.startPrank(vm.addr(key));
        zap.zapIntoLido{value: 1 ether}(
            block.timestamp, abi.encodePacked(r, s, v)
        );

        // stETH shares are equal 1:1 to ETH.
        assertEq(
            manager.stakerStrategyShares(signer, address(lidoStrategy)), 1 ether
        );
    }

    function testZapIntoRocketPool() public {
        uint256 expected = rEth.getRethValue(1e18) * (1e18 - rocketSettingsDeposit.getDepositFee()) / 1e18;

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            key,
            zap.computeDigest(
                address(rocketStrategy),
                address(rEth),
                expected,
                0,
                block.timestamp
            )
        );

        vm.deal(signer, 1 ether);
        vm.startPrank(signer);

        zap.zapIntoRocketPool{value: 1 ether}(
            block.timestamp, abi.encodePacked(r, s, v)
        );

        // rETH shares are not equal 1:1 to ETH.
        assertEq(manager.stakerStrategyShares(signer, address(rocketStrategy)), expected);
    }
}
