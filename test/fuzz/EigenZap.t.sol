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
        vm.selectFork(vm.createFork("https://eth.llamarpc.com", 17480446));

        target = new EigenZap(
            STRATEGY_MANAGER,
            LIDO_ETH,
            ROCKET_ETH,
            LIDO_STRATEGY,
            ROCKET_STRATEGY,
            ROCKET_DEPOSIT_POOL,
            ROCKET_DEPOSIT_SETTINGS
        );

        key = 420;
        signer = vm.addr(key);

        vm.label(address(target), "target");
        vm.label(signer, "signer");
        vm.label(address(this), "test");

        label();
    }

    function test_ZapIntoLido(uint88 amount) public {
        vm.assume(amount > 0.1 ether);
        // Added due to max deposit constraints
        vm.assume(amount < 32 ether);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            key,
            target.computeDigest(
                address(LIDO_STRATEGY),
                address(LIDO_ETH),
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

    function test_ZapIntoRocketPool(uint88 amount) public {
        vm.pauseGasMetering();

        vm.assume(amount > 0.1 ether);
        // Added due to max deposit constraints
        vm.assume(amount < 32 ether);

        uint256 expected = ROCKET_ETH.getRethValue(amount)
            * (1e18 - ROCKET_DEPOSIT_SETTINGS.getDepositFee()) / 1e18;

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            key,
            target.computeDigest(
                address(ROCKET_STRATEGY),
                address(ROCKET_ETH),
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
                signer, address(ROCKET_STRATEGY)
            ),
            expected
        );
        assertEq(signer.balance, 0);
        assertEq(address(target).balance, 0);
        vm.resumeGasMetering();
    }
}
