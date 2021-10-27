# ✨ So you want to sponsor a contest

This `README.md` contains a set of checklists for our contest collaboration.

Your contest will use two repos:
- **a _contest_ repo** (this one), which is used for scoping your contest and for providing information to contestants (wardens)
- **a _findings_ repo**, where issues are submitted.

Ultimately, when we launch the contest, this contest repo will be made public and will contain the smart contracts to be reviewed and all the information needed for contest participants. The findings repo will be made public after the contest is over and your team has mitigated the identified issues.

Some of the checklists in this doc are for **C4 (🐺)** and some of them are for **you as the contest sponsor (⭐️)**.

---

# Contest setup

## ⭐️ Sponsor: Provide contest details

Under "SPONSORS ADD INFO HERE" heading below, include the following:

- [ ] Name of each contract and:
  - [ ] lines of code in each
  - [ ] external contracts called in each
  - [ ] libraries used in each
- [ ] Describe any novel or unique curve logic or mathematical models implemented in the contracts
- [ ] Does the token conform to the ERC-20 standard? In what specific ways does it differ?
- [ ] Describe anything else that adds any special logic that makes your approach unique
- [ ] Identify any areas of specific concern in reviewing the code
- [ ] Add all of the code to this repo that you want reviewed
- [ ] Create a PR to this repo with the above changes.

---

# ⭐️ Sponsor: Provide marketing details

- [ ] Your logo (URL or add file to this repo - SVG or other vector format preferred)
- [ ] Your primary Twitter handle
- [ ] Any other Twitter handles we can/should tag in (e.g. organizers' personal accounts, etc.)
- [ ] Your Discord URI
- [ ] Your website
- [ ] Optional: Do you have any quirks, recurring themes, iconic tweets, community "secret handshake" stuff we could work in? How do your people recognize each other, for example?
- [ ] Optional: your logo in Discord emoji format

---

# Contest prep

## ⭐️ Sponsor: Contest prep
- [ ] Make sure your code is thoroughly commented using the [NatSpec format](https://docs.soliditylang.org/en/v0.5.10/natspec-format.html#natspec-format).
- [ ] Modify the bottom of this `README.md` file to describe how your code is supposed to work with links to any relevent documentation and any other criteria/details that the C4 Wardens should keep in mind when reviewing. ([Here's a well-constructed example.](https://github.com/code-423n4/2021-06-gro/blob/main/README.md))
- [ ] Please have final versions of contracts and documentation added/updated in this repo **no less than 8 hours prior to contest start time.**
- [ ] Ensure that you have access to the _findings_ repo where issues will be submitted.
- [ ] Promote the contest on Twitter (optional: tag in relevant protocols, etc.)
- [ ] Share it with your own communities (blog, Discord, Telegram, email newsletters, etc.)
- [ ] Optional: pre-record a high-level overview of your protocol (not just specific smart contract functions). This saves wardens a lot of time wading through documentation.
- [ ] Designate someone (or a team of people) to monitor DMs & questions in the C4 Discord (**#questions** channel) daily (Note: please *don't* discuss issues submitted by wardens in an open channel, as this could give hints to other wardens.)
- [ ] Delete this checklist and all text above the line below when you're ready.

---

# Slingshot contest details
- $33,250 worth of ETH main award pot
- $1,750 worth of ETH gas optimization award pot
- Join [C4 Discord](https://discord.gg/code4rena) to register
- Submit findings [using the C4 form](https://code423n4.com/2021-10-slingshot-finance-contest/submit)
- [Read our guidelines for more details](https://docs.code4rena.com/roles/wardens)
- Starts October 30, 2021 00:00 UTC
- Ends November 1, 2021 23:59 UTC

This repo will be made public before the start of the contest. (C4 delete this line when made public)

[ ⭐️ SPONSORS ADD INFO HERE ]
## Contracts
### Slingshot (LOC: 182)
Slingshot.sol defines the general logic by which a transaction is handled and executed.

The specific logic for each DEX/AMM is defined within its own corresponding module that is stored in the module registry.

Slingshot.sol references these modules to appropriately execute a trade. Slingshot.sol also performs some safety checks to account for slippage and security. Slingshot.sol expect parameters to be passed from the Slingshot backend that provide the details related to how a given transaction should be executed.

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

ModuleRegistry.sol admin should be able to register new modules at will for smooth development process. This role is trusted admin however, he should not be able to introduce any system wide backdoors by registering malicious modules. For example, it should not be possible for a ModuleRegistry.sol admin to abuse user's approvals.

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
