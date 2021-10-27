# ⭐️ Slingshot contest details
- $33,250 worth of ETH main award pot
- $1,750 worth of ETH gas optimization award pot
- Join [C4 Discord](https://discord.gg/code4rena) to register
- Submit findings [using the C4 form](https://code423n4.com/2021-10-slingshot-finance-contest/submit)
- [Read our guidelines for more details](https://docs.code4rena.com/roles/wardens)
- Starts October 30, 2021 00:00 UTC
- Ends November 1, 2021 23:59 UTC

This repo will be made public before the start of the contest. (C4 delete this line when made public)

## ✨ Contracts
### Slingshot (LOC: 182)
Slingshot.sol defines the general logic by which a transaction is handled and executed.

The specific logic for each DEX/AMM is defined within its own corresponding module that is stored in the module registry.

Slingshot.sol references these modules to appropriately execute a trade. Slingshot.sol also performs some safety checks to account for slippage and security. Slingshot.sol expect parameters to be passed from the Slingshot backend that provide the details related to how a given transaction should be executed.
`rescueTokens` and `rescueTokensFromExecutioner` can be gamed however it is not a concern. They are in place "just in case" and should not be used in the first place.

#### External calls
- ApprovalHandler
- Executioner
- ModuleRegistry
#### Libraries used
- SafeERC20
- ConcatStrings

### ModuleRegistry (LOC: 76)
All modules must be registered in ModuleRegistry.sol. Only trusted code can be registered as a module by registry admin.

### ApprovalHandler (LOC: 44)
It handles all users approvals. It exists to separate the approvals from execution layer. Operated by System admin.

System admin is a multisig and is the most trusted role in the system. It has the power to accept new version of Slingshot protocol and carry over all user approvals.

### Executioner (LOC: 72)
Creates separate execution environment for trades. Big reason for this contract to exists is to decouple roles of ModuleRegistry.sol admin and System admin.

ModuleRegistry.sol admin should be able to register new modules at will for smooth development process. This role is trusted admin however, he should not be able to introduce any system wide backdoors by registering malicious modules. For example, it should not be possible for a ModuleRegistry.sol admin to abuse user's approvals given to ApprovalHandler.sol.

#### External calls
- BalancerV2ModuleMatic
- CurveModule
- SushiSwapModule
- UniswapModule
#### Libraries used
- SafeERC20
- ConcatStrings

### Adminable (LOC: 24)
Access control contract based on OpenZeppelin's AccessControl.

### BalancerModule (LOC: 59)
Trading module for Balancer protocol.
#### External calls
- Balancer
#### Libraries used
- LibERC20Token

### BalancerV2ModuleMatic (LOC: 72)
Trading module for BalancerV2 protocol.
#### External calls
- BalancerV2
#### Libraries used
- LibERC20Token

### CurveModule (LOC: 62)
Trading module for Curve protocol.
#### External calls
- Curve
#### Libraries used
- LibERC20Token

### SushiSwapModule (LOC: 13)
Trading module for SushiSwap protocol.
#### External calls
- SushiSwap
#### Libraries used
- LibERC20Token

### UniswapModule (LOC: 13)
Trading module for Uniswap protocol.
#### External calls
- Uniswap
#### Libraries used
- LibERC20Token
