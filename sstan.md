# Sstan - v0.1.0 

 --- 
 TODO: add description

# Summary




## Vulnerabilities 

 | Classification | Title | Instances | 
 |:-------:|:---------|:-------:| 
## Optimizations 

 | Classification | Title | Instances | 
 |:-------:|:---------|:-------:| 
 | [[Gas-0]](#[Gas-0]) | Use assembly to hash instead of Solidity | 1 |
 | [[Gas-1]](#[Gas-1]) | Mark functions as payable (with discretion) | 1 |
## Quality Assurance 

 | Classification | Title | Instances | 
 |:-------:|:---------|:-------:| 
 | [[NonCritical-0]](#[NonCritical-0]) | Constructor should check that all parameters are not 0 | 7 |
 | [[NonCritical-1]](#[NonCritical-1]) | Contract names should be in PascalCase | 2 |
 | [[NonCritical-2]](#[NonCritical-2]) | Function names should be in camelCase | 3 |
 | [[NonCritical-3]](#[NonCritical-3]) | Consider importing specific identifiers instead of the whole file | 2 |
 | [[NonCritical-4]](#[NonCritical-4]) | Function parameters should be in camelCase | 20 |

## Vulnerabilities - Total: 0 




## Optimizations - Total: 2 

<a name=[Gas-0]></a>
### [Gas-0] Use assembly to hash instead of Solidity - Instances: 1 

 > 
 Hashing is a safe operation to perform in assembly, and it is cheaper than Solidity's `keccak256` function. - Savings: ~82 
 

 --- 

File:EigenZap.sol#L154
```solidity
153:        return keccak256(
154:            abi.encodePacked(
155:                "\x19\x01",
156:                STRATEGY_MANAGER.DOMAIN_SEPARATOR(),
157:                keccak256(
158:                    abi.encode(
159:                        keccak256(
160:                            "Deposit(address strategy,address token,uint256 amount,uint256 nonce,uint256 expiry)"
161:                        ),
162:                        strategy,
163:                        token,
164:                        amount,
165:                        nonce,
166:                        expiry
167:                    )
168:                )
169:            )
170:        );
``` 



File:EigenZap.sol#L158
```solidity
157:                keccak256(
158:                    abi.encode(
159:                        keccak256(
160:                            "Deposit(address strategy,address token,uint256 amount,uint256 nonce,uint256 expiry)"
161:                        ),
162:                        strategy,
163:                        token,
164:                        amount,
165:                        nonce,
166:                        expiry
167:                    )
168:                )
169:            )
``` 



File:EigenZap.sol#L160
```solidity
159:                        keccak256(
160:                            "Deposit(address strategy,address token,uint256 amount,uint256 nonce,uint256 expiry)"
161:                        ),
``` 



 --- 

<a name=[Gas-1]></a>
### [Gas-1] Mark functions as payable (with discretion) - Instances: 1 

 > 
 You can mark public or external functions as payable to save gas. Functions that are not payable have additional logic to check if there was a value sent with a call, however, making a function payable eliminates this check. This optimization should be carefully considered due to potentially unwanted behavior when a function does not need to accept ether. - Savings: ~24 
 

 --- 

File:EigenZap.sol#L147
```solidity
146:    function computeDigest(
147:        address strategy,
148:        address token,
149:        uint256 amount,
150:        uint256 nonce,
151:        uint256 expiry
152:    ) external view returns (bytes32) {
``` 



 --- 



## Quality Assurance - Total: 34 

<a name=[NonCritical-0]></a>
### [NonCritical-0] Constructor should check that all parameters are not 0 - Instances: 7 

 > Consider adding a require statement to check that all parameters are not 0 in the constructor 

 --- 

File:EigenZap.sol#L60
```solidity
59:    constructor(
60:        StrategyManager manager,
61:        stETH stEth,
62:        rETH rEth,
63:        address lidoStrategy,
64:        address rocketStrategy,
65:        RocketDepositPool rocketDepositPool,
66:        RocketDAOProtocolSettingsDeposit rocketSettingsDeposit
67:    ) {
``` 



File:EigenZap.sol#L60
```solidity
59:    constructor(
60:        StrategyManager manager,
61:        stETH stEth,
62:        rETH rEth,
63:        address lidoStrategy,
64:        address rocketStrategy,
65:        RocketDepositPool rocketDepositPool,
66:        RocketDAOProtocolSettingsDeposit rocketSettingsDeposit
67:    ) {
``` 



File:EigenZap.sol#L60
```solidity
59:    constructor(
60:        StrategyManager manager,
61:        stETH stEth,
62:        rETH rEth,
63:        address lidoStrategy,
64:        address rocketStrategy,
65:        RocketDepositPool rocketDepositPool,
66:        RocketDAOProtocolSettingsDeposit rocketSettingsDeposit
67:    ) {
``` 



File:EigenZap.sol#L60
```solidity
59:    constructor(
60:        StrategyManager manager,
61:        stETH stEth,
62:        rETH rEth,
63:        address lidoStrategy,
64:        address rocketStrategy,
65:        RocketDepositPool rocketDepositPool,
66:        RocketDAOProtocolSettingsDeposit rocketSettingsDeposit
67:    ) {
``` 



File:EigenZap.sol#L60
```solidity
59:    constructor(
60:        StrategyManager manager,
61:        stETH stEth,
62:        rETH rEth,
63:        address lidoStrategy,
64:        address rocketStrategy,
65:        RocketDepositPool rocketDepositPool,
66:        RocketDAOProtocolSettingsDeposit rocketSettingsDeposit
67:    ) {
``` 



File:EigenZap.sol#L60
```solidity
59:    constructor(
60:        StrategyManager manager,
61:        stETH stEth,
62:        rETH rEth,
63:        address lidoStrategy,
64:        address rocketStrategy,
65:        RocketDepositPool rocketDepositPool,
66:        RocketDAOProtocolSettingsDeposit rocketSettingsDeposit
67:    ) {
``` 



File:EigenZap.sol#L60
```solidity
59:    constructor(
60:        StrategyManager manager,
61:        stETH stEth,
62:        rETH rEth,
63:        address lidoStrategy,
64:        address rocketStrategy,
65:        RocketDepositPool rocketDepositPool,
66:        RocketDAOProtocolSettingsDeposit rocketSettingsDeposit
67:    ) {
``` 



 --- 

<a name=[NonCritical-1]></a>
### [NonCritical-1] Contract names should be in PascalCase - Instances: 2 

 > Ensure that contract definitions are declared using PascalCase 

 --- 

File:EigenZap.sol#L194
```solidity
193:abstract contract stETH {
194:    function submit(address referral)
195:        external
196:        payable
197:        virtual
198:        returns (uint256);
199:}
200:
``` 



File:EigenZap.sol#L202
```solidity
201:abstract contract rETH {
202:    function getRethValue(uint256 ethAmount)
203:        external
204:        view
205:        virtual
206:        returns (uint256);
207:}
208:
``` 



 --- 

<a name=[NonCritical-2]></a>
### [NonCritical-2] Function names should be in camelCase - Instances: 3 

 > Ensure that function definitions are declared using camelCase 

 --- 

File:EigenZap.sol#L191
```solidity
190:    function DOMAIN_SEPARATOR() external view virtual returns (bytes32);
``` 



File:EigenZap.sol#L195
```solidity
194:    function submit(address referral)
195:        external
196:        payable
197:        virtual
198:        returns (uint256);
``` 



File:EigenZap.sol#L211
```solidity
210:    function deposit() external payable virtual;
``` 



 --- 

<a name=[NonCritical-3]></a>
### [NonCritical-3] Consider importing specific identifiers instead of the whole file - Instances: 2 

 > This will minimize compiled code size and help with readability 

 --- 

File:EigenZap.sol#L4
```solidity
3:import "solady/src/utils/SafeTransferLib.sol";
``` 



File:EigenZap.sol#L5
```solidity
4:import "solady/src/utils/FixedPointMathLib.sol";
``` 



 --- 

<a name=[NonCritical-4]></a>
### [NonCritical-4] Function parameters should be in camelCase - Instances: 20 

 > Ensure that function parameters are declared using camelCase 

 --- 

File:EigenZap.sol#L61
```solidity
60:        StrategyManager manager,
``` 



File:EigenZap.sol#L91
```solidity
90:    function zapIntoLido(uint256 expiry, bytes calldata signature)
``` 



File:EigenZap.sol#L91
```solidity
90:    function zapIntoLido(uint256 expiry, bytes calldata signature)
``` 



File:EigenZap.sol#L114
```solidity
113:    function zapIntoRocketPool(uint256 expiry, bytes calldata signature)
``` 



File:EigenZap.sol#L114
```solidity
113:    function zapIntoRocketPool(uint256 expiry, bytes calldata signature)
``` 



File:EigenZap.sol#L148
```solidity
147:        address strategy,
``` 



File:EigenZap.sol#L149
```solidity
148:        address token,
``` 



File:EigenZap.sol#L150
```solidity
149:        uint256 amount,
``` 



File:EigenZap.sol#L151
```solidity
150:        uint256 nonce,
``` 



File:EigenZap.sol#L152
```solidity
151:        uint256 expiry
152:    ) external view returns (bytes32) {
``` 



File:EigenZap.sol#L177
```solidity
176:        address strategy,
``` 



File:EigenZap.sol#L178
```solidity
177:        address token,
``` 



File:EigenZap.sol#L179
```solidity
178:        uint256 amount,
``` 



File:EigenZap.sol#L180
```solidity
179:        address staker,
``` 



File:EigenZap.sol#L181
```solidity
180:        uint256 expiry,
``` 



File:EigenZap.sol#L182
```solidity
181:        bytes memory signature
182:    ) external virtual returns (uint256 shares);
``` 



File:EigenZap.sol#L183
```solidity
182:    ) external virtual returns (uint256 shares);
``` 



File:EigenZap.sol#L185
```solidity
184:    function stakerStrategyShares(address account, address strategy)
``` 



File:EigenZap.sol#L185
```solidity
184:    function stakerStrategyShares(address account, address strategy)
``` 



File:EigenZap.sol#L195
```solidity
194:    function submit(address referral)
``` 



 --- 


