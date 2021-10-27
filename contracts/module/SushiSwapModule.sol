// SPDX-License-Identifier: AGPLv3
pragma solidity 0.8.7;
pragma abicoder v2;

import "./IUniswapModule.sol";

/// @title Slingshot SushiSwap Module
contract SushiSwapModule is IUniswapModule {
    function getRouter() override public pure returns (address) {
        return 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F;
    }
}
