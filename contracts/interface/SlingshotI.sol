// SPDX-License-Identifier: AGPLv3
pragma solidity 0.8.7;
pragma abicoder v2;

interface SlingshotI {
    struct TradeFormat {
        address moduleAddress;
        bytes encodedCalldata;
    }
}
