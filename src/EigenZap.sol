// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "solady/src/utils/SafeTransferLib.sol";
import "solady/src/utils/FixedPointMathLib.sol";

/**
 * @title EigenZap
 * @dev Facilitates seamless fund transfers into Lido and Rocket Pool
 *      to acquire EigenLayer shares.
 */
contract EigenZap {
    // ------------------------------------------------------------------------
    // Dependencies
    // ------------------------------------------------------------------------

    using SafeTransferLib for address;

    using FixedPointMathLib for uint256;

    // ------------------------------------------------------------------------
    // Immutables
    // ------------------------------------------------------------------------

    /// @notice Immutable reference to the EigenLayer StrategyManager contract.
    StrategyManager public immutable STRATEGY_MANAGER;

    /// @notice Immutable reference to the stETH contract.
    stETH public immutable LIDO_ETH;

    /// @notice Immutable reference to the rETH contract.
    rETH public immutable ROCKET_ETH;

    /// @notice Immutable reference to the Lido strategy contract.
    address public immutable LIDO_ETH_STRATEGY;

    /// @notice Immutable reference to the Rocket strategy contract.
    address public immutable ROCKET_ETH_STRATEGY;

    /// @notice Immutable reference to the RocketDepositPool contract.
    RocketDepositPool public immutable ROCKET_DEPOSIT_POOL;

    /// @notice Immutable reference to the RocketDAOProtocolSettingsDeposit contract.
    RocketDAOProtocolSettingsDeposit public immutable ROCKET_DEPOSIT_SETTINGS;

    // ------------------------------------------------------------------------
    // Construction
    // ------------------------------------------------------------------------

    /**
     * @dev Constructor initializes the contract with immutable references to various contracts.
     * @param manager The StrategyManager contract address.
     * @param stEth The stETH contract address.
     * @param rEth The rETH contract address.
     * @param lidoStrategy The Lido strategy contract address.
     * @param rocketStrategy The Rocket strategy contract address.
     * @param rocketDepositPool The RocketDepositPool contract address.
     * @param rocketSettingsDeposit The RocketDAOProtocolSettingsDeposit contract address.
     */
    constructor(
        StrategyManager manager,
        stETH stEth,
        rETH rEth,
        address lidoStrategy,
        address rocketStrategy,
        RocketDepositPool rocketDepositPool,
        RocketDAOProtocolSettingsDeposit rocketSettingsDeposit
    ) {
        STRATEGY_MANAGER = manager;
        LIDO_ETH = stEth;
        ROCKET_ETH = rEth;
        ROCKET_DEPOSIT_POOL = rocketDepositPool;
        LIDO_ETH_STRATEGY = lidoStrategy;
        ROCKET_ETH_STRATEGY = rocketStrategy;
        ROCKET_DEPOSIT_SETTINGS = rocketSettingsDeposit;

        // Approve maximum allowance for spending stETH and rETH by the STRATEGY_MANAGER contract.
        address(stEth).safeApprove(address(manager), type(uint256).max);
        address(rEth).safeApprove(address(manager), type(uint256).max);
    }

    // ------------------------------------------------------------------------
    // Actions
    // ------------------------------------------------------------------------

    /**
     * @notice Facilitates the transfer of funds into Lido to acquire EigenLayer shares.
     * @param expiry The expiration timestamp for the transaction.
     * @param signature The signature for the transaction.
     *
     * @dev There is a small amount of precision loss when depositing into Lido.
     */
    function zapIntoLido(uint256 expiry, bytes memory signature)
        external
        payable
        virtual
    {
        // 1) Deposit ETH into Lido to receive stETH.
        LIDO_ETH.submit{value: msg.value}(address(0));

        // 2) Deposit stETH into the strategy to receive EigenLayer shares.
        STRATEGY_MANAGER.depositIntoStrategyWithSignature(
            LIDO_ETH_STRATEGY,
            address(LIDO_ETH),
            msg.value,
            msg.sender,
            expiry,
            signature
        );
    }

    /**
     * @notice Facilitates the transfer of funds into RocketPool to acquire EigenLayer shares.
     * @param expiry The expiration timestamp for the transaction.
     * @param signature The signature for the transaction.
     */
    function zapIntoRocketPool(uint256 expiry, bytes memory signature)
        external
        payable
        virtual
    {
        // 1) Deposit ETH into RocketPool to receive rETH.
        ROCKET_DEPOSIT_POOL.deposit{value: msg.value}();

        // 2) Deposit RocketDepositPool into the strategy to receive EigenLayer shares.
        STRATEGY_MANAGER.depositIntoStrategyWithSignature(
            ROCKET_ETH_STRATEGY,
            address(ROCKET_ETH),
            ROCKET_ETH.getRethValue(msg.value).mulWad(
                uint256(1e18).rawSub(ROCKET_DEPOSIT_SETTINGS.getDepositFee())
            ),
            msg.sender,
            expiry,
            signature
        );
    }

    /**
     * @notice Recovers assets accidentally sent to this contract.
     * @param asset The address of the asset to be recovered. Use address(0) for ETH.
     */
    function recover(address asset) external virtual {
        if (asset == address(0)) {
            msg.sender.safeTransferAllETH();
        }

        asset.safeTransferAll(msg.sender);
    }

    // ------------------------------------------------------------------------
    // Helpers
    // ------------------------------------------------------------------------

    /**
     * @dev Computes the digest for a given strategy deposit, used for signature verification.
     * @param strategy The strategy contract address.
     * @param token The token address.
     * @param amount The deposit amount.
     * @param nonce The transaction nonce.
     * @param expiry The expiration timestamp for the transaction.
     * @return The computed digest.
     */
    function computeDigest(
        address strategy,
        address token,
        uint256 amount,
        uint256 nonce,
        uint256 expiry
    ) external view returns (bytes32) {
        return keccak256(
            abi.encodePacked(
                "\x19\x01",
                STRATEGY_MANAGER.DOMAIN_SEPARATOR(),
                keccak256(
                    abi.encode(
                        keccak256(
                            "Deposit(address strategy,address token,uint256 amount,uint256 nonce,uint256 expiry)"
                        ),
                        strategy,
                        token,
                        amount,
                        nonce,
                        expiry
                    )
                )
            )
        );
    }
}

abstract contract StrategyManager {
    function depositIntoStrategyWithSignature(
        address strategy,
        address token,
        uint256 amount,
        address staker,
        uint256 expiry,
        bytes memory signature
    ) external virtual returns (uint256 shares);

    function stakerStrategyShares(address account, address strategy)
        external
        view
        virtual
        returns (uint256);

    function DOMAIN_SEPARATOR() external view virtual returns (bytes32);
}

abstract contract stETH {
    function submit(address referral)
        external
        payable
        virtual
        returns (uint256);
}

abstract contract rETH {
    function getRethValue(uint256 ethAmount)
        external
        view
        virtual
        returns (uint256);
}

abstract contract RocketDepositPool {
    function deposit() external payable virtual;
}

abstract contract RocketDAOProtocolSettingsDeposit {
    function getDepositFee() external view virtual returns (uint256);
}
