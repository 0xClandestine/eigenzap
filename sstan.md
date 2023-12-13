# Sstan - v0.1.0 

 --- 
 TODO: add description

# Summary




## Vulnerabilities 

 | Classification | Title | Instances | 
 |:-------:|:---------|:-------:| 
 | [[Low-0]](#[Low-0]) | Use a locked pragma version instead of a floating pragma version | 1 |
 | [[Low-1]](#[Low-1]) | Unsafe ERC20 Operation | 2 |
## Optimizations 

 | Classification | Title | Instances | 
 |:-------:|:---------|:-------:| 
 | [[Gas-0]](#[Gas-0]) | Use `calldata` instead of `memory` for function arguments that do not get mutated. | 1 |
 | [[Gas-1]](#[Gas-1]) | Use assembly to hash instead of Solidity | 1 |
 | [[Gas-2]](#[Gas-2]) | Use assembly for math (add, sub, mul, div) | 1 |
 | [[Gas-3]](#[Gas-3]) | Right shift or Left shift instead of dividing or multiplying by powers of two | 1 |
 | [[Gas-4]](#[Gas-4]) | Mark functions as payable (with discretion) | 1 |
## Quality Assurance 

 | Classification | Title | Instances | 
 |:-------:|:---------|:-------:| 
 | [[NonCritical-0]](#[NonCritical-0]) | Constructor should check that all parameters are not 0 | 7 |
 | [[NonCritical-1]](#[NonCritical-1]) | Contract names should be in PascalCase | 2 |
 | [[NonCritical-2]](#[NonCritical-2]) | Function names should be in camelCase | 4 |
 | [[NonCritical-3]](#[NonCritical-3]) | Require/Revert statements should be consistent across the codebase | 7 |
 | [[NonCritical-4]](#[NonCritical-4]) | Constant and immutable variable names should be in SCREAMING_SNAKE_CASE | 7 |
 | [[NonCritical-5]](#[NonCritical-5]) | Function parameters should be in camelCase | 22 |

## Vulnerabilities - Total: 3 

<a name=[Low-0]></a>
### [Low-0] Use a locked pragma version instead of a floating pragma version - Instances: 1 

 > ""
        Floating pragma is a vulnerability in smart contract code that can cause unexpected behavior by allowing the compiler to use a specified range of versions. \n This can lead to issues such as using an older compiler version with known vulnerabilities, using a newer compiler version with undiscovered vulnerabilities, inconsistency across files using different versions, or unpredictable behavior because the compiler can use any version within the specified range. It is recommended to use a locked pragma version in order to avoid these potential vulnerabilities. In some cases it may be acceptable to use a floating pragma, such as when a contract is intended for consumption by other developers and needs to be compatible with a range of compiler versions.
        <details>
        <summary>Expand Example</summary>

        #### Bad

        ```js
            pragma solidity ^0.8.0;
        ```

        #### Good

        ```js
            pragma solidity 0.8.15;
        ```
        </details>
        "" 

 --- 

File:EigenZap.sol#L2
```solidity
1:pragma solidity ^0.8.13;
``` 



 --- 

<a name=[Low-1]></a>
### [Low-1] Unsafe ERC20 Operation - Instances: 2 

 > ""
        ERC20 operations can be unsafe due to different implementations and vulnerabilities in the standard. To account for this, either use OpenZeppelin's SafeERC20 library or wrap each operation in a require statement. \n
        > Additionally, ERC20's approve functions have a known race-condition vulnerability. To account for this, use OpenZeppelin's SafeERC20 library's `safeIncrease` or `safeDecrease` Allowance functions.
        <details>
        <summary>Expand Example</summary>

        #### Unsafe Transfer

        ```js
        IERC20(token).transfer(msg.sender, amount);
        ```

        #### OpenZeppelin SafeTransfer

        ```js
        import {SafeERC20} from \"openzeppelin/token/utils/SafeERC20.sol\";
        //--snip--

        IERC20(token).safeTransfer(msg.sender, address(this), amount);
        ```
                
        #### Safe Transfer with require statement.

        ```js
        bool success = IERC20(token).transfer(msg.sender, amount);
        require(success, \"ERC20 transfer failed\");
        ```
                
        #### Unsafe TransferFrom

        ```js
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        ```

        #### OpenZeppelin SafeTransferFrom

        ```js
        import {SafeERC20} from \"openzeppelin/token/utils/SafeERC20.sol\";
        //--snip--

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        ```
                
        #### Safe TransferFrom with require statement.

        ```js
        bool success = IERC20(token).transferFrom(msg.sender, address(this), amount);
        require(success, \"ERC20 transfer failed\");
        ```

        </details>
        "" 

 --- 

File:EigenZap.sol#L67
```solidity
66:        ERC20Approve(address(_stEth)).approve(
``` 



File:EigenZap.sol#L70
```solidity
69:        ERC20Approve(address(_rEth)).approve(
``` 



 --- 



## Optimizations - Total: 5 

<a name=[Gas-0]></a>
### [Gas-0] Use `calldata` instead of `memory` for function arguments that do not get mutated. - Instances: 1 

 > 
 Mark data types as `calldata` instead of `memory` where possible. This makes it so that the data is not automatically loaded into memory. If the data passed into the function does not need to be changed (like updating values in an array), it can be passed in as `calldata`. The one exception to this is if the argument must later be passed into another function that takes an argument that specifies `memory` storage. - Savings: ~1716 
 

 --- 

File:EigenZap.sol#L84
```solidity
83:    function zapIntoLido(uint256 expiry, bytes memory signature)
``` 



File:EigenZap.sol#L107
```solidity
106:    function zapIntoRocketPool(uint256 expiry, bytes memory signature)
``` 



 --- 

<a name=[Gas-1]></a>
### [Gas-1] Use assembly to hash instead of Solidity - Instances: 1 

 > 
 Hashing is a safe operation to perform in assembly, and it is cheaper than Solidity's `keccak256` function. - Savings: ~82 
 

 --- 

File:EigenZap.sol#L146
```solidity
145:        return keccak256(
146:            abi.encodePacked(
147:                "\x19\x01",
148:                manager.DOMAIN_SEPARATOR(),
149:                keccak256(
150:                    abi.encode(
151:                        keccak256(
152:                            "Deposit(address strategy,address token,uint256 amount,uint256 nonce,uint256 expiry)"
153:                        ),
154:                        strategy,
155:                        token,
156:                        amount,
157:                        nonce,
158:                        expiry
159:                    )
160:                )
161:            )
162:        );
``` 



File:EigenZap.sol#L150
```solidity
149:                keccak256(
150:                    abi.encode(
151:                        keccak256(
152:                            "Deposit(address strategy,address token,uint256 amount,uint256 nonce,uint256 expiry)"
153:                        ),
154:                        strategy,
155:                        token,
156:                        amount,
157:                        nonce,
158:                        expiry
159:                    )
160:                )
161:            )
``` 



File:EigenZap.sol#L152
```solidity
151:                        keccak256(
152:                            "Deposit(address strategy,address token,uint256 amount,uint256 nonce,uint256 expiry)"
153:                        ),
``` 



 --- 

<a name=[Gas-2]></a>
### [Gas-2] Use assembly for math (add, sub, mul, div) - Instances: 1 

 > 
 Use assembly for math instead of Solidity. You can check for overflow/underflow in assembly to ensure safety. If using Solidity versions < 0.8.0 and you are using Safemath, you can gain significant gas savings by using assembly to calculate values and checking for overflow/underflow. - Savings: ~60 
 

 --- 

File:EigenZap.sol#L118
```solidity
117:            rEth.getRethValue(msg.value)
118:                * (1e18 - rocketSettingsDeposit.getDepositFee()) / 1e18,
``` 



File:EigenZap.sol#L118
```solidity
117:            rEth.getRethValue(msg.value)
118:                * (1e18 - rocketSettingsDeposit.getDepositFee()) / 1e18,
``` 



File:EigenZap.sol#L119
```solidity
118:                * (1e18 - rocketSettingsDeposit.getDepositFee()) / 1e18,
``` 



 --- 

<a name=[Gas-3]></a>
### [Gas-3] Right shift or Left shift instead of dividing or multiplying by powers of two - Instances: 1 

 > 
 Right shift or left shift when possible to save gas. - Savings: ~65 
 

 --- 

File:EigenZap.sol#L118
```solidity
117:            rEth.getRethValue(msg.value)
118:                * (1e18 - rocketSettingsDeposit.getDepositFee()) / 1e18,
``` 



 --- 

<a name=[Gas-4]></a>
### [Gas-4] Mark functions as payable (with discretion) - Instances: 1 

 > 
 You can mark public or external functions as payable to save gas. Functions that are not payable have additional logic to check if there was a value sent with a call, however, making a function payable eliminates this check. This optimization should be carefully considered due to potentially unwanted behavior when a function does not need to accept ether. - Savings: ~24 
 

 --- 

File:EigenZap.sol#L139
```solidity
138:    function computeDigest(
139:        address strategy,
140:        address token,
141:        uint256 amount,
142:        uint256 nonce,
143:        uint256 expiry
144:    ) external view returns (bytes32) {
``` 



 --- 



## Quality Assurance - Total: 49 

<a name=[NonCritical-0]></a>
### [NonCritical-0] Constructor should check that all parameters are not 0 - Instances: 7 

 > Consider adding a require statement to check that all parameters are not 0 in the constructor 

 --- 

File:EigenZap.sol#L49
```solidity
48:    constructor(
49:        StrategyManager _manager,
50:        stETH _stEth,
51:        rETH _rEth,
52:        address _lidoStrategy,
53:        address _rocketStrategy,
54:        RocketDepositPool _rocketDepositPool,
55:        RocketDAOProtocolSettingsDeposit _rocketSettingsDeposit
56:    ) {
``` 



File:EigenZap.sol#L49
```solidity
48:    constructor(
49:        StrategyManager _manager,
50:        stETH _stEth,
51:        rETH _rEth,
52:        address _lidoStrategy,
53:        address _rocketStrategy,
54:        RocketDepositPool _rocketDepositPool,
55:        RocketDAOProtocolSettingsDeposit _rocketSettingsDeposit
56:    ) {
``` 



File:EigenZap.sol#L49
```solidity
48:    constructor(
49:        StrategyManager _manager,
50:        stETH _stEth,
51:        rETH _rEth,
52:        address _lidoStrategy,
53:        address _rocketStrategy,
54:        RocketDepositPool _rocketDepositPool,
55:        RocketDAOProtocolSettingsDeposit _rocketSettingsDeposit
56:    ) {
``` 



File:EigenZap.sol#L49
```solidity
48:    constructor(
49:        StrategyManager _manager,
50:        stETH _stEth,
51:        rETH _rEth,
52:        address _lidoStrategy,
53:        address _rocketStrategy,
54:        RocketDepositPool _rocketDepositPool,
55:        RocketDAOProtocolSettingsDeposit _rocketSettingsDeposit
56:    ) {
``` 



File:EigenZap.sol#L49
```solidity
48:    constructor(
49:        StrategyManager _manager,
50:        stETH _stEth,
51:        rETH _rEth,
52:        address _lidoStrategy,
53:        address _rocketStrategy,
54:        RocketDepositPool _rocketDepositPool,
55:        RocketDAOProtocolSettingsDeposit _rocketSettingsDeposit
56:    ) {
``` 



File:EigenZap.sol#L49
```solidity
48:    constructor(
49:        StrategyManager _manager,
50:        stETH _stEth,
51:        rETH _rEth,
52:        address _lidoStrategy,
53:        address _rocketStrategy,
54:        RocketDepositPool _rocketDepositPool,
55:        RocketDAOProtocolSettingsDeposit _rocketSettingsDeposit
56:    ) {
``` 



File:EigenZap.sol#L49
```solidity
48:    constructor(
49:        StrategyManager _manager,
50:        stETH _stEth,
51:        rETH _rEth,
52:        address _lidoStrategy,
53:        address _rocketStrategy,
54:        RocketDepositPool _rocketDepositPool,
55:        RocketDAOProtocolSettingsDeposit _rocketSettingsDeposit
56:    ) {
``` 



 --- 

<a name=[NonCritical-1]></a>
### [NonCritical-1] Contract names should be in PascalCase - Instances: 2 

 > Ensure that contract definitions are declared using PascalCase 

 --- 

File:EigenZap.sol#L186
```solidity
185:abstract contract stETH {
186:    function submit(address referral)
187:        external
188:        payable
189:        virtual
190:        returns (uint256);
191:}
192:
``` 



File:EigenZap.sol#L194
```solidity
193:abstract contract rETH {
194:    function getRethValue(uint256 ethAmount)
195:        external
196:        view
197:        virtual
198:        returns (uint256);
199:}
200:
``` 



 --- 

<a name=[NonCritical-2]></a>
### [NonCritical-2] Function names should be in camelCase - Instances: 4 

 > Ensure that function definitions are declared using camelCase 

 --- 

File:EigenZap.sol#L183
```solidity
182:    function DOMAIN_SEPARATOR() external view virtual returns (bytes32);
``` 



File:EigenZap.sol#L187
```solidity
186:    function submit(address referral)
187:        external
188:        payable
189:        virtual
190:        returns (uint256);
``` 



File:EigenZap.sol#L203
```solidity
202:    function approve(address spender, uint256 value)
203:        external
204:        virtual
205:        returns (bool);
``` 



File:EigenZap.sol#L210
```solidity
209:    function deposit() external payable virtual;
``` 



 --- 

<a name=[NonCritical-3]></a>
### [NonCritical-3] Require/Revert statements should be consistent across the codebase - Instances: 7 

 > Consider using require/revert statements consistently across the codebase 

 --- 

File:EigenZap.sol#L15
```solidity
14:    StrategyManager public immutable manager;
``` 



File:EigenZap.sol#L18
```solidity
17:    stETH public immutable stEth;
``` 



File:EigenZap.sol#L21
```solidity
20:    rETH public immutable rEth;
``` 



File:EigenZap.sol#L24
```solidity
23:    address public immutable lidoStrategy;
``` 



File:EigenZap.sol#L27
```solidity
26:    address public immutable rocketStrategy;
``` 



File:EigenZap.sol#L30
```solidity
29:    RocketDepositPool public immutable rocketDepositPool;
``` 



File:EigenZap.sol#L33
```solidity
32:    RocketDAOProtocolSettingsDeposit public immutable rocketSettingsDeposit;
``` 



 --- 

<a name=[NonCritical-4]></a>
### [NonCritical-4] Constant and immutable variable names should be in SCREAMING_SNAKE_CASE - Instances: 7 

 > Ensure that Constant and immutable variable names are declared using SCREAMING_SNAKE_CASE 

 --- 

File:EigenZap.sol#L15
```solidity
14:    StrategyManager public immutable manager;
``` 



File:EigenZap.sol#L18
```solidity
17:    stETH public immutable stEth;
``` 



File:EigenZap.sol#L21
```solidity
20:    rETH public immutable rEth;
``` 



File:EigenZap.sol#L24
```solidity
23:    address public immutable lidoStrategy;
``` 



File:EigenZap.sol#L27
```solidity
26:    address public immutable rocketStrategy;
``` 



File:EigenZap.sol#L30
```solidity
29:    RocketDepositPool public immutable rocketDepositPool;
``` 



File:EigenZap.sol#L33
```solidity
32:    RocketDAOProtocolSettingsDeposit public immutable rocketSettingsDeposit;
``` 



 --- 

<a name=[NonCritical-5]></a>
### [NonCritical-5] Function parameters should be in camelCase - Instances: 22 

 > Ensure that function parameters are declared using camelCase 

 --- 

File:EigenZap.sol#L50
```solidity
49:        StrategyManager _manager,
``` 



File:EigenZap.sol#L84
```solidity
83:    function zapIntoLido(uint256 expiry, bytes memory signature)
``` 



File:EigenZap.sol#L84
```solidity
83:    function zapIntoLido(uint256 expiry, bytes memory signature)
``` 



File:EigenZap.sol#L107
```solidity
106:    function zapIntoRocketPool(uint256 expiry, bytes memory signature)
``` 



File:EigenZap.sol#L107
```solidity
106:    function zapIntoRocketPool(uint256 expiry, bytes memory signature)
``` 



File:EigenZap.sol#L140
```solidity
139:        address strategy,
``` 



File:EigenZap.sol#L141
```solidity
140:        address token,
``` 



File:EigenZap.sol#L142
```solidity
141:        uint256 amount,
``` 



File:EigenZap.sol#L143
```solidity
142:        uint256 nonce,
``` 



File:EigenZap.sol#L144
```solidity
143:        uint256 expiry
144:    ) external view returns (bytes32) {
``` 



File:EigenZap.sol#L169
```solidity
168:        address strategy,
``` 



File:EigenZap.sol#L170
```solidity
169:        address token,
``` 



File:EigenZap.sol#L171
```solidity
170:        uint256 amount,
``` 



File:EigenZap.sol#L172
```solidity
171:        address staker,
``` 



File:EigenZap.sol#L173
```solidity
172:        uint256 expiry,
``` 



File:EigenZap.sol#L174
```solidity
173:        bytes memory signature
174:    ) external virtual returns (uint256 shares);
``` 



File:EigenZap.sol#L175
```solidity
174:    ) external virtual returns (uint256 shares);
``` 



File:EigenZap.sol#L177
```solidity
176:    function stakerStrategyShares(address account, address strategy)
``` 



File:EigenZap.sol#L177
```solidity
176:    function stakerStrategyShares(address account, address strategy)
``` 



File:EigenZap.sol#L187
```solidity
186:    function submit(address referral)
``` 



File:EigenZap.sol#L203
```solidity
202:    function approve(address spender, uint256 value)
``` 



File:EigenZap.sol#L203
```solidity
202:    function approve(address spender, uint256 value)
``` 



 --- 


