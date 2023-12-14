// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "src/EigenZap.sol";
import "test/Constants.sol";

contract EigenZapTest is Test {
    uint256 key;
    address signer;

    EigenZap target;

    function setUp() public {
        // 17480446 is the last block eigen deposits haven't been paused, or at max tvl.
        vm.selectFork(
            vm.createFork(
                "https://eth.llamarpc.com",
                17480446
            )
        );

        target = new EigenZap(
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

        vm.label(address(target), "target");
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

    function testzapIntoLido(uint88 amount) public {
        vm.assume(amount > 0.1 ether);
        // Added due to max deposit constraints
        vm.assume(amount < 32 ether);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            key,
            target.computeDigest(
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
        target.zapIntoLido{value: amount}(
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
        assertEq(address(target).balance, 0);
        vm.resumeGasMetering();
    }

    function testzapIntoRocketPool(uint88 amount) public {
        vm.pauseGasMetering();

        vm.assume(amount > 0.1 ether);
        // Added due to max deposit constraints
        vm.assume(amount < 32 ether);

        uint256 expected = ROCKET_POOL_ETH.getRethValue(amount)
            * (1e18 - ROCKET_DEPOSIT_SETTINGS.getDepositFee()) / 1e18;

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            key,
            target.computeDigest(
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
        target.zapIntoRocketPool{value: amount}(
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
        assertEq(address(target).balance, 0);
        vm.resumeGasMetering();
    }
}
