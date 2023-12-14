# EigenZap

EigenZap is a smart contract designed to facilitate seamless fund transfers into Lido and Rocket Pool to acquire EigenLayer shares. This contract streamlines the process of obtaining EigenLayer shares by managing the interaction with Lido and Rocket Pool strategies. EigenLayer shares are acquired by depositing ETH into Lido to receive stETH or by depositing ETH into Rocket Pool to receive rETH.

## How it Works

### Dependencies

EigenZap relies on the following contracts:
- **StrategyManager**: Manages the deposit into strategies for Lido and Rocket Pool.
- **stETH**: Represents the staked ETH contract.
- **rETH**: Represents the Rocket Pool ETH contract.
- **RocketDepositPool**: Manages deposits into Rocket Pool.
- **RocketDAOProtocolSettingsDeposit**: Provides deposit fee information.

### Construction

The contract is constructed with references to the immutable addresses of the above contracts. Approval for maximum allowances for spending stETH and rETH is set during construction.

### Actions

#### Zap into Lido
- Function: `zapIntoLido`
- Action:
  1. Deposit ETH into Lido to receive stETH.
  2. Deposit stETH into the strategy to receive EigenLayer shares.

#### Zap into Rocket Pool
- Function: `zapIntoRocketPool`
- Action:
  1. Deposit ETH into Rocket Pool to receive rETH.
  2. Deposit rETH into the strategy to receive EigenLayer shares.

### Helpers

#### Compute Digest
- Function: `computeDigest`
- Purpose: Computes the digest for a given strategy deposit for signature verification.

## Usage

1. Deploy the EigenZap contract with the addresses of the required dependencies.
2. Call `zapIntoLido` or `zapIntoRocketPool` with the desired amount of ETH, expiration timestamp, and signature.
3. Check the acquired EigenLayer shares in the respective strategies.

## License

This repository is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
