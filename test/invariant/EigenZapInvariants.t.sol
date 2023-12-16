// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";

import "test/invariant/EigenZapHandler.t.sol";
import "test/Constants.sol";

import "src/EigenZap.sol";

contract EigenZapInvariants is StdInvariant, Test {
    EigenZapHandler handler;

    function setUp() public {
        vm.selectFork(vm.createFork("https://eth.llamarpc.com", TEST_BLOCK));

        EigenZap target = new EigenZap(
            EIGEN_STRATEGY_MANAGER,
            LIDO_ETH,
            ROCKET_ETH,
            LIDO_STRATEGY,
            ROCKET_STRATEGY,
            ROCKET_DEPOSIT_POOL,
            ROCKET_DEPOSIT_SETTINGS
        );

        handler = new EigenZapHandler(target);
    }

    function invariant_no_balance_growth() public {
        address target = address(handler.target());
        assertEq(address(target).balance, 0);
        assertEq(SafeTransferLib.balanceOf(address(LIDO_ETH), target), 0);
        assertEq(SafeTransferLib.balanceOf(address(ROCKET_ETH), target), 0);
    }

    function invariant_deposits_equal_shares_lido() public {
        assertApproxEqRel(handler.totalEthInLido(), handler.totalSharesOutLido(), 0.005 ether);
    }

    function invariant_deposits_equal_shares_rocket() public {
        assertEq(
            ROCKET_ETH.getRethValue(handler.totalEthInRocket())
                * (1e18 - ROCKET_DEPOSIT_SETTINGS.getDepositFee()) / 1e18,
            handler.totalSharesOutRocket()
        );
    }
}
