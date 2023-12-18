// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";

import "test/Constants.sol";
import "src/EigenZap.sol";

contract EigenZapHandler is Test {
    EigenZap public target;

    mapping(uint256 => uint256) nonces;

    uint256 public totalEthInLido;
    uint256 public totalEthInRocket;
    uint256 public totalSharesOutLido;
    uint256 public totalSharesOutRocket;

    constructor(EigenZap _target) {
        target = _target;
    }

    function zapIntoLido(uint256 key, uint256 amount, uint256 expiry) external {
        key = boundPrivateKey(key);
        amount = bound(amount, 0.5 ether, 32 ether);
        expiry = bound(expiry, block.timestamp, type(uint256).max);

        totalEthInLido += amount;

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            key,
            target.computeDigest(
                address(LIDO_STRATEGY), address(LIDO_ETH), amount, nonces[key]++, expiry
            )
        );

        address signer = vm.addr(key);

        vm.prank(signer);
        vm.deal(signer, amount);
        target.zapIntoLido{value: amount}(expiry, abi.encodePacked(r, s, v));

        totalSharesOutLido += EIGEN_STRATEGY_MANAGER.stakerStrategyShares(signer, LIDO_STRATEGY);
    }

    function zapIntoRocketPool(uint256 key, uint256 amount, uint256 expiry) external {
        key = boundPrivateKey(key);
        amount = bound(amount, 0.5 ether, 32 ether);
        expiry = bound(expiry, block.timestamp, type(uint256).max);

        totalEthInRocket += amount;

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            key,
            target.computeDigest(
                address(LIDO_STRATEGY), address(LIDO_ETH), amount, nonces[key]++, expiry
            )
        );

        address signer = vm.addr(key);

        vm.prank(signer);
        vm.deal(signer, amount);
        target.zapIntoRocketPool{value: amount}(expiry, abi.encodePacked(r, s, v));

        totalSharesOutRocket += EIGEN_STRATEGY_MANAGER.stakerStrategyShares(signer, ROCKET_STRATEGY);
    }
}
