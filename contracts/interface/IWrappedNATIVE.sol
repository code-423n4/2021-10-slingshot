// SPDX-License-Identifier: AGPLv3
pragma solidity 0.8.7;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IWrappedNATIVE is IERC20 {
    function deposit() external payable;
    function withdraw(uint256 amount) external;
}
