// SPDX-License-Identifier: AGPLv3
pragma solidity 0.8.7;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../lib/LibERC20Token.sol";
import "./ISlingshotModule.sol";

interface IBalancerVault {
    enum SwapKind { GIVEN_IN, GIVEN_OUT }

    struct SingleSwap {
        bytes32 poolId;
        SwapKind kind;
        address assetIn; // originally IAsset
        address assetOut; // originally IAsset
        uint256 amount;
        bytes userData;
    }

    struct FundManagement {
        address sender;
        bool fromInternalBalance;
        address payable recipient;
        bool toInternalBalance;
    }

    function swap(
        SingleSwap memory singleSwap,
        FundManagement memory funds,
        uint256 limit,
        uint256 deadline
    )
    external payable returns (uint256 amountCalculated);
}

/// @title Slingshot Balancer Module
contract BalancerV2ModuleMatic is ISlingshotModule {
    using LibERC20Token for IERC20;

    address public constant vault = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;

    function swap(
        bytes32 poolId,
        address tokenIn,
        address tokenOut,
        uint256 totalAmountIn,
        bool tradeAll
    ) external payable {
        if (tradeAll) {
            totalAmountIn = IERC20(tokenIn).balanceOf(address(this));
        }

        IERC20(tokenIn).approveIfBelow(vault, totalAmountIn);

        IBalancerVault.SingleSwap memory singleSwap = IBalancerVault.SingleSwap(
          poolId, IBalancerVault.SwapKind.GIVEN_IN, tokenIn, tokenOut, totalAmountIn, ""
        );

        IBalancerVault.FundManagement memory funds = IBalancerVault.FundManagement(
          address(this), false, payable(address(this)), false
        );

        IBalancerVault(vault).swap(
            singleSwap,
            funds,
            1,
            block.timestamp
        );
    }
}
