// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import "src/EigenZap.sol";
import "test/Constants.sol";

contract EigenZapTest is Test {
    uint256 key;
    address signer;
    uint256 rocketDepositFee;

    EigenZap target;

    function setUp() public {
        // 17480206 is the last block eigen deposits haven't been paused, or at max tvl.
        vm.selectFork(vm.createFork("https://eth.llamarpc.com", TEST_BLOCK));

        target = new EigenZap(
            EIGEN_STRATEGY_MANAGER,
            LIDO_ETH,
            ROCKET_ETH,
            LIDO_STRATEGY,
            ROCKET_STRATEGY,
            ROCKET_DEPOSIT_POOL,
            ROCKET_DEPOSIT_SETTINGS
        );

        key = 420;
        signer = vm.addr(key);

        vm.label(address(target), "EIGEN_ZAP");
        vm.label(signer, "EIGEN_ZAP_SIGNER");
        vm.label(address(this), "EIGEN_ZAP_TEST");

        rocketDepositFee = ROCKET_DEPOSIT_SETTINGS.getDepositFee();

        label();
    }

    function test_ZapIntoLido(uint256 amount, uint256 expiry) public {
        vm.pauseGasMetering();
        amount = bound(amount, 0.1 ether, 32 ether);
        expiry = bound(expiry, block.timestamp, type(uint256).max);

        (uint8 v, bytes32 r, bytes32 s) =
            vm.sign(key, target.computeDigest(LIDO_STRATEGY, address(LIDO_ETH), amount, 0, expiry));

        vm.deal(signer, amount);
        vm.startPrank(vm.addr(key));
        vm.resumeGasMetering();
        target.zapIntoLido{value: amount}(expiry, abi.encodePacked(r, s, v));
        vm.pauseGasMetering();
        // stETH shares are equal 1:1 to ETH, minus some precision loss.
        assertApproxEqRel(
            EIGEN_STRATEGY_MANAGER.stakerStrategyShares(signer, LIDO_STRATEGY), amount, 0.005 ether
        );
        assertEq(signer.balance, 0);
        assertEq(address(target).balance, 0);
        vm.resumeGasMetering();
    }

    function test_ZapIntoRocketPool(uint256 amount, uint256 expiry) public {
        vm.pauseGasMetering();
        amount = bound(amount, 0.1 ether, 32 ether);
        expiry = bound(expiry, block.timestamp, type(uint256).max);

        uint256 expected = ROCKET_ETH.getRethValue(amount) * (1e18 - rocketDepositFee) / 1e18;

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            key, target.computeDigest(ROCKET_STRATEGY, address(ROCKET_ETH), expected, 0, expiry)
        );

        vm.deal(signer, amount);
        vm.startPrank(signer);
        vm.resumeGasMetering();
        target.zapIntoRocketPool{value: amount}(expiry, abi.encodePacked(r, s, v));
        vm.pauseGasMetering();
        // rETH shares are not equal 1:1 to ETH.
        assertEq(EIGEN_STRATEGY_MANAGER.stakerStrategyShares(signer, ROCKET_STRATEGY), expected);
        assertEq(signer.balance, 0);
        assertEq(address(target).balance, 0);
        vm.resumeGasMetering();
    }
}
