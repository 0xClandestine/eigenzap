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
 | [[Gas-0]](#[Gas-0]) | Use assembly to check for address(0) | 1 |
 | [[Gas-1]](#[Gas-1]) | Use `calldata` instead of `memory` for function arguments that do not get mutated. | 1 |
 | [[Gas-2]](#[Gas-2]) | Use assembly to hash instead of Solidity | 1 |
 | [[Gas-3]](#[Gas-3]) | Mark functions as payable (with discretion) | 1 |
## Quality Assurance 

 | Classification | Title | Instances | 
 |:-------:|:---------|:-------:| 
 | [[NonCritical-0]](#[NonCritical-0]) | Constructor should check that all parameters are not 0 | 7 |
 | [[NonCritical-1]](#[NonCritical-1]) | Contract names should be in PascalCase | 2 |
 | [[NonCritical-2]](#[NonCritical-2]) | Function names should be in camelCase | 4 |
 | [[NonCritical-3]](#[NonCritical-3]) | Consider importing specific identifiers instead of the whole file | 2 |
 | [[NonCritical-4]](#[NonCritical-4]) | Function parameters should be in camelCase | 21 |

## Vulnerabilities - Total: 0 




## Optimizations - Total: 4 

<a name=[Gas-0]></a>
### [Gas-0] Use assembly to check for address(0) - Instances: 1 

 > 
  - Savings: ~6 
 

 --- 

File:EigenZap.sol#L143
```solidity
142:        if (asset == address(0)) {
``` 



 --- 

<a name=[Gas-1]></a>
### [Gas-1] Use `calldata` instead of `memory` for function arguments that do not get mutated. - Instances: 1 

 > 
 Mark data types as `calldata` instead of `memory` where possible. This makes it so that the data is not automatically loaded into memory. If the data passed into the function does not need to be changed (like updating values in an array), it can be passed in as `calldata`. The one exception to this is if the argument must later be passed into another function that takes an argument that specifies `memory` storage. - Savings: ~1716 
 

 --- 

File:EigenZap.sol#L93
```solidity
92:    function zapIntoLido(uint256 expiry, bytes memory signature)
``` 



File:EigenZap.sol#L117
```solidity
116:    function zapIntoRocketPool(uint256 expiry, bytes memory signature)
``` 



 --- 

<a name=[Gas-2]></a>
### [Gas-2] Use assembly to hash instead of Solidity - Instances: 1 

 > 
 Hashing is a safe operation to perform in assembly, and it is cheaper than Solidity's `keccak256` function. - Savings: ~82 
 

 --- 

File:EigenZap.sol#L170
```solidity
169:        return keccak256(
170:            abi.encodePacked(
171:                "\x19\x01",
172:                EIGEN_STRATEGY_MANAGER.DOMAIN_SEPARATOR(),
173:                keccak256(
174:                    abi.encode(
175:                        keccak256(
176:                            "Deposit(address strategy,address token,uint256 amount,uint256 nonce,uint256 expiry)"
177:                        ),
178:                        strategy,
179:                        token,
180:                        amount,
181:                        nonce,
182:                        expiry
183:                    )
184:                )
185:            )
186:        );
``` 



File:EigenZap.sol#L174
```solidity
173:                keccak256(
174:                    abi.encode(
175:                        keccak256(
176:                            "Deposit(address strategy,address token,uint256 amount,uint256 nonce,uint256 expiry)"
177:                        ),
178:                        strategy,
179:                        token,
180:                        amount,
181:                        nonce,
182:                        expiry
183:                    )
184:                )
185:            )
``` 



File:EigenZap.sol#L176
```solidity
175:                        keccak256(
176:                            "Deposit(address strategy,address token,uint256 amount,uint256 nonce,uint256 expiry)"
177:                        ),
``` 



 --- 

<a name=[Gas-3]></a>
### [Gas-3] Mark functions as payable (with discretion) - Instances: 1 

 > 
 You can mark public or external functions as payable to save gas. Functions that are not payable have additional logic to check if there was a value sent with a call, however, making a function payable eliminates this check. This optimization should be carefully considered due to potentially unwanted behavior when a function does not need to accept ether. - Savings: ~24 
 

 --- 

File:EigenZap.sol#L142
```solidity
141:    function recover(address asset) external virtual {
``` 



File:EigenZap.sol#L163
```solidity
162:    function computeDigest(
163:        address strategy,
164:        address token,
165:        uint256 amount,
166:        uint256 nonce,
167:        uint256 expiry
168:    ) external view returns (bytes32) {
``` 



 --- 



## Quality Assurance - Total: 36 

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

File:EigenZap.sol#L210
```solidity
209:abstract contract stETH {
210:    function submit(address referral)
211:        external
212:        payable
213:        virtual
214:        returns (uint256);
215:}
216:
``` 



File:EigenZap.sol#L218
```solidity
217:abstract contract rETH {
218:    function getRethValue(uint256 ethAmount)
219:        external
220:        view
221:        virtual
222:        returns (uint256);
223:}
224:
``` 



 --- 

<a name=[NonCritical-2]></a>
### [NonCritical-2] Function names should be in camelCase - Instances: 4 

 > Ensure that function definitions are declared using camelCase 

 --- 

File:EigenZap.sol#L142
```solidity
141:    function recover(address asset) external virtual {
``` 



File:EigenZap.sol#L207
```solidity
206:    function DOMAIN_SEPARATOR() external view virtual returns (bytes32);
``` 



File:EigenZap.sol#L211
```solidity
210:    function submit(address referral)
211:        external
212:        payable
213:        virtual
214:        returns (uint256);
``` 



File:EigenZap.sol#L227
```solidity
226:    function deposit() external payable virtual;
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
### [NonCritical-4] Function parameters should be in camelCase - Instances: 21 

 > Ensure that function parameters are declared using camelCase 

 --- 

File:EigenZap.sol#L61
```solidity
60:        StrategyManager manager,
``` 



File:EigenZap.sol#L93
```solidity
92:    function zapIntoLido(uint256 expiry, bytes memory signature)
``` 



File:EigenZap.sol#L93
```solidity
92:    function zapIntoLido(uint256 expiry, bytes memory signature)
``` 



File:EigenZap.sol#L117
```solidity
116:    function zapIntoRocketPool(uint256 expiry, bytes memory signature)
``` 



File:EigenZap.sol#L117
```solidity
116:    function zapIntoRocketPool(uint256 expiry, bytes memory signature)
``` 



File:EigenZap.sol#L142
```solidity
141:    function recover(address asset) external virtual {
``` 



File:EigenZap.sol#L164
```solidity
163:        address strategy,
``` 



File:EigenZap.sol#L165
```solidity
164:        address token,
``` 



File:EigenZap.sol#L166
```solidity
165:        uint256 amount,
``` 



File:EigenZap.sol#L167
```solidity
166:        uint256 nonce,
``` 



File:EigenZap.sol#L168
```solidity
167:        uint256 expiry
168:    ) external view returns (bytes32) {
``` 



File:EigenZap.sol#L193
```solidity
192:        address strategy,
``` 



File:EigenZap.sol#L194
```solidity
193:        address token,
``` 



File:EigenZap.sol#L195
```solidity
194:        uint256 amount,
``` 



File:EigenZap.sol#L196
```solidity
195:        address staker,
``` 



File:EigenZap.sol#L197
```solidity
196:        uint256 expiry,
``` 



File:EigenZap.sol#L198
```solidity
197:        bytes memory signature
198:    ) external virtual returns (uint256 shares);
``` 



File:EigenZap.sol#L199
```solidity
198:    ) external virtual returns (uint256 shares);
``` 



File:EigenZap.sol#L201
```solidity
200:    function stakerStrategyShares(address account, address strategy)
``` 



File:EigenZap.sol#L201
```solidity
200:    function stakerStrategyShares(address account, address strategy)
``` 



File:EigenZap.sol#L211
```solidity
210:    function submit(address referral)
``` 



 --- 


