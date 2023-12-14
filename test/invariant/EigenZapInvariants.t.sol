// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";

import "test/invariant/EigenZapHandler.t.sol";
import "test/Constants.sol";

import "src/EigenZap.sol";

contract EigenZapInvariants is StdInvariant, Test {
    EigenZapHandler handler;

    function setUp() public {
        vm.selectFork(
            vm.createFork(
                "https://eth.llamarpc.com",
                17480446
            )
        );

        EigenZap target = new EigenZap(
            STRATEGY_MANAGER,
            LIDO_STAKED_ETH,
            ROCKET_POOL_ETH,
            LIDO_STRATEGY,
            ROCKET_POOL_STRATEGY,
            ROCKET_DEPOSIT_POOL,
            ROCKET_DEPOSIT_SETTINGS
        );

        handler = new EigenZapHandler(target);
    }

    function invariant_no_balance_growth() public {
        address target = address(handler.target());
        assertEq(address(target).balance, 0);
        assertEq(SafeTransferLib.balanceOf(address(LIDO_STAKED_ETH), target), 0);
        assertEq(SafeTransferLib.balanceOf(address(ROCKET_POOL_ETH), target), 0);
    }

    function invariant_deposits_equal_shares() public {
        assertApproxEqAbs(
            handler.totalEthInLido(), handler.totalSharesOutLido(), 100 wei
        );
        assertEq(
            ROCKET_POOL_ETH.getRethValue(handler.totalEthInRocket())
                * (1e18 - ROCKET_DEPOSIT_SETTINGS.getDepositFee()) / 1e18,
            handler.totalSharesOutRocket()
        );
    }
}
