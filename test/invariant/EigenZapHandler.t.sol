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

    function zapIntoLido(uint256 key, uint256 amount, uint256 expiry)
        external
    {
        amount = bound(amount, 0.1 ether, 32 ether);

        totalEthInLido += amount;

        if (expiry < block.timestamp) {
            expiry = block.timestamp;
        }

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            key,
            target.computeDigest(
                address(LIDO_STRATEGY),
                address(LIDO_ETH),
                amount,
                nonces[key]++,
                expiry
            )
        );

        address signer = vm.addr(key);

        vm.prank(signer);
        vm.deal(signer, amount);
        target.zapIntoLido{value: amount}(expiry, abi.encodePacked(r, s, v));

        totalSharesOutLido += STRATEGY_MANAGER.stakerStrategyShares(
            signer, address(LIDO_STRATEGY)
        );
    }

    function zapIntoRocketPool(uint256 key, uint256 amount, uint256 expiry)
        external
    {
        amount = bound(amount, 0.1 ether, 32 ether);

        totalEthInRocket += amount;

        if (expiry < block.timestamp) {
            expiry = block.timestamp;
        }

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            key,
            target.computeDigest(
                address(LIDO_STRATEGY),
                address(LIDO_ETH),
                amount,
                nonces[key]++,
                expiry
            )
        );

        address signer = vm.addr(key);

        vm.prank(signer);
        vm.deal(signer, amount);
        target.zapIntoRocketPool{value: amount}(
            expiry, abi.encodePacked(r, s, v)
        );

        totalSharesOutRocket += STRATEGY_MANAGER.stakerStrategyShares(
            signer, address(ROCKET_STRATEGY)
        );
    }
}
