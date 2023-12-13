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
    address constant LIDO_STRATEGY = 0x93c4b944D05dfe6df7645A86cd2206016c51564D;
    address constant ROCKET_POOL_STRATEGY =
        0x1BeE69b7dFFfA4E2d53C2a2Df135C388AD25dCD2;
    RocketDepositPool constant ROCKET_DEPOSIT_POOL =
        RocketDepositPool(0xDD3f50F8A6CafbE9b31a427582963f465E745AF8);
    RocketDAOProtocolSettingsDeposit constant ROCKET_DEPOSIT_SETTINGS =
    RocketDAOProtocolSettingsDeposit(0xac2245BE4C2C1E9752499Bcd34861B761d62fC27);

    uint256 key;
    address signer;

    EigenZap zap;

    function setUp() public {
        // 17480446 is the last block eigen deposits haven't been paused, or at max tvl.
        vm.selectFork(vm.createFork("https://eth.llamarpc.com", 17480446));

        zap = new EigenZap(
            STRATEGY_MANAGER,
            LIDO_STAKED_ETH,
            ROCKET_POOL_ETH,
            LIDO_STRATEGY,
            ROCKET_POOL_STRATEGY,
            ROCKET_DEPOSIT_POOL,
            ROCKET_DEPOSIT_SETTINGS
        );

        key = 420;
        signer = vm.addr(key);

        vm.label(address(zap), "zap");
        vm.label(signer, "signer");
        vm.label(address(this), "test");

        vm.label(address(LIDO_STAKED_ETH), "LIDO_STAKED_ETH");
        vm.label(address(ROCKET_POOL_ETH), "ROCKET_POOL_ETH");

        vm.label(address(ROCKET_DEPOSIT_POOL), "ROCKET_DEPOSIT_POOL");
        vm.label(address(ROCKET_DEPOSIT_SETTINGS), "ROCKET_DEPOSIT_SETTINGS");

        vm.label(0xb8FFC3Cd6e7Cf5a098A1c92F48009765B24088Dc, "EIGEN_KERNAL");
        vm.label(0x2b33CF282f867A7FF693A66e11B0FcC5552e4425, "EIGEN_KERNAL_2");
        vm.label(0x17144556fd3424EDC8Fc8A4C940B2D04936d17eb, "LIDO");

        vm.label(address(STRATEGY_MANAGER), "EIGEN_STRATEGY_MANAGER");
        vm.label(0x39053D51B77DC0d36036Fc1fCc8Cb819df8Ef37A, "EIGEN_DELEGATION");
        vm.label(
            0x7Fe7E9CC0F274d2435AD5d56D5fa73E47F6A23D8,
            "EIGEN_DELAYED_WITHDRAWAL_ROUTER"
        );
        vm.label(
            0x44Bcb0E01CD0C5060D4Bb1A07b42580EF983E2AF,
            "EIGEN_DELAYED_WITHDRAWAL_ROUTER_IMPL"
        );

        vm.label(
            0x0c431C66F4dE941d089625E5B423D00707977060, "EIGEN_LAYER_PAUSER_REG"
        );
        vm.label(
            0x8b9566AdA63B64d1E1dcF1418b43fd1433b72444,
            "EIGEN_LAYER_PROXY_ADMIN"
        );
        vm.label(0x5a2a4F2F3C18f09179B6703e63D9eDD165909073, "EIGEN_POD_BEACON");
        vm.label(
            0x91E677b07F7AF907ec9a428aafA9fc14a0d3A338, "EIGEN_POD_MANAGER"
        );
        vm.label(
            0xEB86a5c40FdE917E6feC440aBbCDc80E3862e111, "EIGEN_POD_MANAGER_IMPL"
        );
        vm.label(0x1f96861fEFa1065a5A96F20Deb6D8DC3ff48F7f9, "EMPTY_CONTRACT");
        vm.label(0xD92145c07f8Ed1D392c1B88017934E301CC1c3Cd, "EIGEN_SLASHER");

        vm.label(0x54945180dB7943c0ed0FEE7EdaB2Bd24620256bc, "STRATEGY_CBETH");
        vm.label(LIDO_STRATEGY, "STRATEGY_STETH");
        vm.label(ROCKET_POOL_STRATEGY, "STRATEGY_RETH");
    }

    function testZapIntoLido(uint88 amount) public {
        vm.pauseGasMetering();
        vm.assume(amount > 0.1 ether);
        // Added due to max deposit constraints
        vm.assume(amount < 32 ether);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            key,
            zap.computeDigest(
                address(LIDO_STRATEGY),
                address(LIDO_STAKED_ETH),
                amount,
                0,
                block.timestamp
            )
        );

        vm.deal(signer, amount);
        vm.startPrank(vm.addr(key));
        vm.resumeGasMetering();
        zap.zapIntoLido{value: amount}(
            block.timestamp, abi.encodePacked(r, s, v)
        );
        vm.pauseGasMetering();
        // stETH shares are equal 1:1 to ETH, minus some precision loss.
        assertApproxEqAbs(
            STRATEGY_MANAGER.stakerStrategyShares(
                signer, address(LIDO_STRATEGY)
            ),
            amount,
            100 wei
        );
        assertEq(signer.balance, 0);
        assertEq(address(zap).balance, 0);
        vm.resumeGasMetering();
    }

    function testZapIntoRocketPool(uint88 amount) public {
        vm.pauseGasMetering();

        vm.assume(amount > 0.1 ether);
        // Added due to max deposit constraints
        vm.assume(amount < 32 ether);

        uint256 expected = ROCKET_POOL_ETH.getRethValue(amount)
            * (1e18 - ROCKET_DEPOSIT_SETTINGS.getDepositFee()) / 1e18;

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            key,
            zap.computeDigest(
                address(ROCKET_POOL_STRATEGY),
                address(ROCKET_POOL_ETH),
                expected,
                0,
                block.timestamp
            )
        );

        vm.deal(signer, amount);
        vm.startPrank(signer);
        vm.resumeGasMetering();
        zap.zapIntoRocketPool{value: amount}(
            block.timestamp, abi.encodePacked(r, s, v)
        );
        vm.pauseGasMetering();
        // rETH shares are not equal 1:1 to ETH.
        assertEq(
            STRATEGY_MANAGER.stakerStrategyShares(
                signer, address(ROCKET_POOL_STRATEGY)
            ),
            expected
        );
        assertEq(signer.balance, 0);
        assertEq(address(zap).balance, 0);
        vm.resumeGasMetering();
    }

    function testZapIntoRocketPoolUnsafe(uint88 amount) public {
        vm.pauseGasMetering();

        vm.assume(amount > 0.1 ether);
        // Added due to max deposit constraints
        vm.assume(amount < 32 ether);

        uint256 rEthDepositFee = ROCKET_DEPOSIT_SETTINGS.getDepositFee();
        uint256 expected =
            ROCKET_POOL_ETH.getRethValue(amount) * (1e18 - rEthDepositFee) / 1e18;

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            key,
            zap.computeDigest(
                address(ROCKET_POOL_STRATEGY),
                address(ROCKET_POOL_ETH),
                expected,
                0,
                block.timestamp
            )
        );

        uint256 rEthValue = ROCKET_POOL_ETH.getRethValue(amount);

        vm.deal(signer, amount);
        vm.startPrank(signer);
        vm.resumeGasMetering();
        zap.zapIntoRocketPoolUnsafe{value: amount}(
            rEthValue, rEthDepositFee, block.timestamp, abi.encodePacked(r, s, v)
        );
        vm.pauseGasMetering();

        // rETH shares are not equal 1:1 to ETH.
        assertEq(
            STRATEGY_MANAGER.stakerStrategyShares(
                signer, address(ROCKET_POOL_STRATEGY)
            ),
            expected
        );
        assertEq(signer.balance, 0);
        assertEq(address(zap).balance, 0);
        vm.resumeGasMetering();
    }
}
