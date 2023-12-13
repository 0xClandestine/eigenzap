// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "../src/EigenZap.sol";

contract EigenZapTest is Test {
    StrategyManager constant STRATEGY_MANAGER =
        StrategyManager(0x858646372CC42E1A627fcE94aa7A7033e7CF075A);
    stETH constant LIDO_STAKED_ETH =
        stETH(0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84);
    rETH constant ROCKET_POOL_ETH =
        rETH(0xae78736Cd615f374D3085123A210448E74Fc6393);
    address constant LIDO_ETH_STRATEGY =
        0x93c4b944D05dfe6df7645A86cd2206016c51564D;
    address constant ROCKET_POOL_ETH_STRATEGY =
        0x1BeE69b7dFFfA4E2d53C2a2Df135C388AD25dCD2;
    RocketDepositPool constant ROCKET_DEPOSIT_POOL =
        RocketDepositPool(0xDD3f50F8A6CafbE9b31a427582963f465E745AF8);
    RocketDAOProtocolSettingsDeposit constant ROCKET_DEPOSIT_SETTINGS =
    RocketDAOProtocolSettingsDeposit(0xac2245BE4C2C1E9752499Bcd34861B761d62fC27);

    uint256 key;
    address signer;

    EigenZap zap;

    function setUp() public {
        vm.selectFork(vm.createFork("https://eth.llamarpc.com", 17480446));

        zap = new EigenZap(
            STRATEGY_MANAGER,
            LIDO_STAKED_ETH,
            ROCKET_POOL_ETH,
            LIDO_ETH_STRATEGY,
            ROCKET_POOL_ETH_STRATEGY,
            ROCKET_DEPOSIT_POOL,
            ROCKET_DEPOSIT_SETTINGS
        );

        key = 420;
        signer = vm.addr(key);

        vm.label(address(zap), "zap");
        vm.label(signer, "signer");
        vm.label(address(this), "test");
        vm.label(address(STRATEGY_MANAGER), "STRATEGY_MANAGER");
        vm.label(address(LIDO_STAKED_ETH), "LIDO_STAKED_ETH");
        vm.label(address(ROCKET_POOL_ETH), "ROCKET_POOL_ETH");
        vm.label(LIDO_ETH_STRATEGY, "LIDO_ETH_STRATEGY");
        vm.label(ROCKET_POOL_ETH_STRATEGY, "ROCKET_POOL_ETH_STRATEGY");
        vm.label(address(ROCKET_DEPOSIT_POOL), "ROCKET_DEPOSIT_POOL");
        vm.label(address(ROCKET_DEPOSIT_SETTINGS), "ROCKET_DEPOSIT_SETTINGS");
    }

    function testZapIntoLido(uint88 amount) public {
        vm.assume(amount > 0.1 ether);
        // Added due to max deposit constraints
        vm.assume(amount < 32 ether);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            key,
            zap.computeDigest(
                address(LIDO_ETH_STRATEGY),
                address(LIDO_STAKED_ETH),
                amount,
                0,
                block.timestamp
            )
        );

        vm.deal(signer, amount);
        vm.startPrank(vm.addr(key));
        zap.zapIntoLido{value: amount}(
            block.timestamp, abi.encodePacked(r, s, v)
        );

        // stETH shares are equal 1:1 to ETH, minus some precision loss.
        assertApproxEqAbs(
            STRATEGY_MANAGER.stakerStrategyShares(
                signer, address(LIDO_ETH_STRATEGY)
            ),
            amount,
            100 wei
        );
        assertEq(signer.balance, 0);
        assertEq(address(zap).balance, 0);
    }

    function testZapIntoRocketPool(uint88 amount) public {
        vm.assume(amount > 0.1 ether);
        // Added due to max deposit constraints
        vm.assume(amount < 32 ether);

        uint256 expected = ROCKET_POOL_ETH.getRethValue(amount)
            * (1e18 - ROCKET_DEPOSIT_SETTINGS.getDepositFee()) / 1e18;

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            key,
            zap.computeDigest(
                address(ROCKET_POOL_ETH_STRATEGY),
                address(ROCKET_POOL_ETH),
                expected,
                0,
                block.timestamp
            )
        );

        vm.deal(signer, amount);
        vm.startPrank(signer);

        // zap.zapIntoRocketPool{value: amount}(
        //     ROCKET_POOL_ETH.getRethValue(amount),
        //     1e18 - ROCKET_DEPOSIT_SETTINGS.getDepositFee(),
        //     block.timestamp,
        //     abi.encodePacked(r, s, v)
        // );

        zap.zapIntoRocketPool{value: amount}(
            block.timestamp, abi.encodePacked(r, s, v)
        );

        // rETH shares are not equal 1:1 to ETH.
        assertEq(
            STRATEGY_MANAGER.stakerStrategyShares(
                signer, address(ROCKET_POOL_ETH_STRATEGY)
            ),
            expected
        );
        assertEq(signer.balance, 0);
        assertEq(address(zap).balance, 0);
    }
}
