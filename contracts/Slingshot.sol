// SPDX-License-Identifier: AGPLv3
pragma solidity 0.8.7;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./interface/SlingshotI.sol";
import "./interface/IWrappedNATIVE.sol";
import "./Adminable.sol";
import "./ModuleRegistry.sol";
import "./ApprovalHandler.sol";
import "./Executioner.sol";

/// @title   Slingshot Trading Contract
/// @author  DEXAG, Inc.
/// @notice  This contract serves as the entrypoint for executing
///          a Slingshot transaction on-chain.
/// @dev     The specific logic for each DEX/AMM is defined within its
///          own corresponding module that is stored in the module registry.
///          Slingshot.sol references these modules to appropriately execute a trade.
///          Slingshot.sol also performs some safety checks to account for slippage
///          and security. Slingshot.sol depends on the Slingshot backend to provide
///          the details of how a given transaction will be executed within a
///          particular market.
contract Slingshot is SlingshotI, Adminable, ConcatStrings, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using SafeERC20 for IWrappedNATIVE;

    /// @dev address of native token, if you are trading ETH on Ethereum,
    ///      matic on Matic etc you should use this address as token from
    address public immutable nativeToken;
    /// @dev address of wrapped native token, for Ethereum it's WETH, for Matic is wmatic etc
    IWrappedNATIVE public immutable wrappedNativeToken;
    Executioner public immutable executioner;

    ModuleRegistry public moduleRegistry;
    ApprovalHandler public approvalHandler;

    event Trade(
        address fromToken,
        address toToken,
        uint256 fromAmount,
        uint256 toAmount,
        address indexed recipient
    );
    event NewModuleRegistry(address oldRegistry, address newRegistry);
    event NewApprovalHandler(address oldApprovalHandler, address approvalHandler);

    constructor (address _admin, address _nativeToken, address _wrappedNativeToken) {
        executioner = new Executioner(_nativeToken, _wrappedNativeToken);
        _setupAdmin(_admin);
        nativeToken = _nativeToken;
        wrappedNativeToken = IWrappedNATIVE(_wrappedNativeToken);
    }

    /// @notice Executes multi-hop trades to get the best result
    ///         It's up to BE to whitelist tokens
    /// @param fromToken Start token address
    /// @param toToken Target token address
    /// @param fromAmount The initial amount of fromToken to start trading with
    /// @param trades Array of encoded trades that are atomically executed
    /// @param finalAmountMin The minimum expected output after all trades have been executed
    /// @param depricated to be removed
    function executeTrades(
        address fromToken,
        address toToken,
        uint256 fromAmount,
        TradeFormat[] calldata trades,
        uint256 finalAmountMin,
        address depricated
    ) external nonReentrant payable {
        depricated;
        require(finalAmountMin > 0, "Slingshot: finalAmountMin cannot be zero");
        require(trades.length > 0, "Slingshot: trades cannot be empty");
        for(uint256 i = 0; i < trades.length; i++) {
            // Checks to make sure that module exists and is correct
            require(moduleRegistry.isModule(trades[i].moduleAddress), "Slingshot: not a module");
        }

        uint256 initialBalance = _getTokenBalance(toToken);
        _transferFromOrWrap(fromToken, _msgSender(), fromAmount);

        executioner.executeTrades(trades);

        uint finalBalance;
        if (toToken == nativeToken) {
            finalBalance = _getTokenBalance(address(wrappedNativeToken));
        } else {
            finalBalance = _getTokenBalance(toToken);
        }
        uint finalOutputAmount = finalBalance - initialBalance;
        require(finalOutputAmount >= finalAmountMin, "Slingshot: result is lower than required min");

        emit Trade(fromToken, toToken, fromAmount, finalOutputAmount, _msgSender());

        // Send to msg.sender.
        executioner.sendFunds(toToken, _msgSender(), finalOutputAmount);
    }

    /// @notice Sets ApprovalHandler that is used to transfer token from users
    /// @param _approvalHandler The address of ApprovalHandler
    function setApprovalHandler(address _approvalHandler) external onlyAdmin {
        emit NewApprovalHandler(address(approvalHandler), _approvalHandler);
        approvalHandler = ApprovalHandler(_approvalHandler);
    }

    /// @notice Sets module registry used to verify modules
    /// @param _moduleRegistry The address of module registry
    function setModuleRegistry(address _moduleRegistry) external onlyAdmin {
        address oldRegistry = address(moduleRegistry);
        moduleRegistry = ModuleRegistry(_moduleRegistry);
        emit NewModuleRegistry(oldRegistry, _moduleRegistry);
    }

    /// @notice In an unlikely scenario of tokens being send to this contract
    ///         allow admin to rescue them.
    /// @param token The address of the token to rescue
    /// @param to The address of recipient
    /// @param amount The amount of the token to rescue
    function rescueTokens(address token, address to, uint256 amount) external onlyAdmin {
        if (token == nativeToken) {
            (bool success, ) = to.call{value: amount}("");
            require(success, "Slingshot: ETH rescue failed.");
        } else {
            IERC20(token).safeTransfer(to, amount);
        }
    }

    /// @notice In an unlikely scenario of tokens being send to this contract
    ///         allow admin to rescue them.
    /// @param token The address of the token to rescue
    /// @param to The address of recipient
    /// @param amount The amount of the token to rescue
    function rescueTokensFromExecutioner(address token, address to, uint256 amount) external onlyAdmin {
        executioner.rescueTokens(token, to, amount);
    }

    /// @notice Transfer tokens from sender to this contract or wraps ETH
    /// @param fromToken The address of the token
    /// @param from The address of sender that provides token
    /// @param amount The amount of the token to transfer
    function _transferFromOrWrap(address fromToken, address from, uint256 amount) internal {
        // transfer tokens or wrap ETH
        if (fromToken == nativeToken) {
            require(msg.value == amount, "Slingshot: incorrect ETH value");
            wrappedNativeToken.deposit{value: amount}();
            wrappedNativeToken.safeTransfer(address(executioner), amount);
        } else {
            approvalHandler.transferFrom(fromToken, from, address(executioner), amount);
        }
    }

    /// @notice Returns balance of the token
    /// @param token The address of the token
    /// @return balance of the token (ERC20 and native)
    function _getTokenBalance(address token) internal view returns (uint256) {
        if (token == nativeToken) {
            return address(executioner).balance;
        } else {
            return IERC20(token).balanceOf(address(executioner));
        }
    }

    /// @notice Sends token funds. For native token, it unwraps wrappedNativeToken
    /// @param token The address of the token to send
    /// @param to The address of recipient
    /// @param amount The amount of the token to send
    function _sendFunds(address token, address to, uint256 amount) internal {
        executioner.sendFunds(token, to, amount);
        if (token == nativeToken) {
            wrappedNativeToken.withdraw(amount);
            (bool success, ) = to.call{value: amount}("");
            require(success, "Slingshot: ETH Transfer failed.");
        } else {
            IERC20(token).safeTransfer(to, amount);
        }
    }

    receive() external payable {}
}
