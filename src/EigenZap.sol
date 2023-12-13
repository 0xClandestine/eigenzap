// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/**
 * @title EigenZap
 * @dev Facilitates seamless fund transfers into Lido and Rocket Pool
 *      to acquire EigenLayer shares.
 */
contract EigenZap {
    // ------------------------------------------------------------------------
    // Immutables
    // ------------------------------------------------------------------------

    /// @notice Immutable reference to the StrategyManager contract.
    StrategyManager public immutable manager;

    /// @notice Immutable reference to the stETH contract.
    stETH public immutable stEth;

    /// @notice Immutable reference to the rETH contract.
    rETH public immutable rEth;

    /// @notice Immutable reference to the Lido strategy contract.
    address public immutable lidoStrategy;

    /// @notice Immutable reference to the Rocket strategy contract.
    address public immutable rocketStrategy;

    /// @notice Immutable reference to the RocketDepositPool contract.
    RocketDepositPool public immutable rocketDepositPool;

    /// @notice Immutable reference to the RocketDAOProtocolSettingsDeposit contract.
    RocketDAOProtocolSettingsDeposit public immutable rocketSettingsDeposit;

    // ------------------------------------------------------------------------
    // Construction
    // ------------------------------------------------------------------------

    /**
     * @dev Constructor initializes the contract with immutable references to various contracts.
     * @param _manager The StrategyManager contract address.
     * @param _stEth The stETH contract address.
     * @param _rEth The rETH contract address.
     * @param _lidoStrategy The Lido strategy contract address.
     * @param _rocketStrategy The Rocket strategy contract address.
     * @param _rocketDepositPool The RocketDepositPool contract address.
     * @param _rocketSettingsDeposit The RocketDAOProtocolSettingsDeposit contract address.
     */
    constructor(
        StrategyManager _manager,
        stETH _stEth,
        rETH _rEth,
        address _lidoStrategy,
        address _rocketStrategy,
        RocketDepositPool _rocketDepositPool,
        RocketDAOProtocolSettingsDeposit _rocketSettingsDeposit
    ) {
        manager = _manager;
        stEth = _stEth;
        rEth = _rEth;
        rocketDepositPool = _rocketDepositPool;
        lidoStrategy = _lidoStrategy;
        rocketStrategy = _rocketStrategy;
        rocketSettingsDeposit = _rocketSettingsDeposit;

        // Approve maximum allowance for spending stETH and rETH by the manager contract.
        ERC20Approve(address(_stEth)).approve(
            address(_manager), type(uint256).max
        );
        ERC20Approve(address(_rEth)).approve(address(_manager), type(uint256).max);
    }

    // ------------------------------------------------------------------------
    // Actions
    // ------------------------------------------------------------------------

    /**
     * @notice Facilitates the transfer of funds into Lido to acquire EigenLayer shares.
     * @param expiry The expiration timestamp for the transaction.
     * @param signature The signature for the transaction.
     */
    function zapIntoLido(uint256 expiry, bytes memory signature)
        external
        payable
    {
        // 1) Deposit ETH into Lido to receive stETH.
        stEth.submit{value: msg.value}(address(0));

        // 2) Deposit stETH into the strategy to receive EigenLayer shares.
        manager.depositIntoStrategyWithSignature(
            lidoStrategy,
            address(stEth),
            msg.value,
            msg.sender,
            expiry,
            signature
        );
    }

    /**
     * @dev Facilitates the transfer of funds into RocketPool to acquire EigenLayer shares.
     * @param expiry The expiration timestamp for the transaction.
     * @param signature The signature for the transaction.
     */
    function zapIntoRocketPool(uint256 expiry, bytes memory signature)
        external
        payable
    {
        // 1) Deposit ETH into RocketPool to receive rETH.
        rocketDepositPool.deposit{value: msg.value}();

        // 2) Deposit RocketDepositPool into the strategy to receive EigenLayer shares.
        manager.depositIntoStrategyWithSignature(
            rocketStrategy,
            address(rEth),
            rEth.getRethValue(msg.value) * (1e18 - rocketSettingsDeposit.getDepositFee()) / 1e18,
            msg.sender,
            expiry,
            signature
        );
    }

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
                manager.DOMAIN_SEPARATOR(),
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

abstract contract ERC20Approve {
    function approve(address spender, uint256 value)
        external
        virtual
        returns (bool);
}

abstract contract RocketDepositPool {
    function deposit() external payable virtual;
}

abstract contract RocketDAOProtocolSettingsDeposit {
    function getDepositFee() external view virtual returns (uint256);
}
