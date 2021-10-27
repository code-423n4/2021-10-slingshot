// SPDX-License-Identifier: AGPLv3
pragma solidity 0.8.7;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interface/SlingshotI.sol";
import "./interface/IWrappedNATIVE.sol";
import "./lib/ConcatStrings.sol";

/// @title   Slingshot Execution Contract
/// @author  DEXAG, Inc.
/// @notice  This contract serves as the isolated execution space for trading contract
///          a Slingshot transaction on-chain.
contract Executioner is SlingshotI, Ownable, ConcatStrings {
    using SafeERC20 for IERC20;

    /// @dev address of native token, if you are trading ETH on Ethereum,
    ///      matic on Matic etc you should use this address as token from
    address public immutable nativeToken;
    /// @dev address of wrapped native token, for Ethereum it's WETH, for Matic is wmatic etc
    IWrappedNATIVE public immutable wrappedNativeToken;

    constructor (address _nativeToken, address _wrappedNativeToken) {
        nativeToken = _nativeToken;
        wrappedNativeToken = IWrappedNATIVE(_wrappedNativeToken);
    }

    /// @notice Executes multi-hop trades to get the best result
    ///         It's up to BE to whitelist tokens
    /// @param trades Array of encoded trades that are atomically executed
    function executeTrades(TradeFormat[] calldata trades) external onlyOwner {
        for(uint256 i = 0; i < trades.length; i++) {
            // delegatecall message is made on module contract, which is trusted
            (bool success, bytes memory data) = trades[i].moduleAddress.delegatecall(trades[i].encodedCalldata);

            require(success, appendString(string(data), appendUint(string("Executioner: swap failed: "), i)));
        }
    }

    /// @notice In an unlikely scenario of tokens being send to this contract
    ///         allow admin to rescue them.
    /// @param token The address of the token to rescue
    /// @param to The address of recipient
    /// @param amount The amount of the token to rescue
    function rescueTokens(address token, address to, uint256 amount) external onlyOwner {
        if (token == nativeToken) {
            (bool success, ) = to.call{value: amount}("");
            require(success, "Executioner: ETH rescue failed.");
        } else {
            IERC20(token).safeTransfer(to, amount);
        }
    }

    /// @notice Sends token funds. For native token, it unwraps wrappedNativeToken
    /// @param token The address of the token to send
    /// @param to The address of recipient
    /// @param amount The amount of the token to send
    function sendFunds(address token, address to, uint256 amount) external onlyOwner {
        if (token == nativeToken) {
            wrappedNativeToken.withdraw(amount);
            (bool success, ) = to.call{value: amount}("");
            require(success, "Executioner: ETH Transfer failed.");
        } else {
            IERC20(token).safeTransfer(to, amount);
        }
    }

    receive() external payable {}
}
