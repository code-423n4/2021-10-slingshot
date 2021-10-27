// SPDX-License-Identifier: AGPLv3
pragma solidity 0.8.7;

import "@openzeppelin/contracts/utils/Strings.sol";

/// @title Strings
/// @notice Utility contract for strings
contract ConcatStrings {
    using Strings for uint256;

    /// @notice Concat two strings
    /// @param str1 String to concat
    /// @param str2 String to concat
    /// @return result Concatenated strings
    function appendString(string memory str1, string memory str2) public pure returns (string memory result) {
        return string(abi.encodePacked(str1, str2));
    }

    /// @notice Concat two strings
    /// @param str1 String to concat
    /// @param i Number to append
    /// @return result Concatenated strings
    function appendUint(string memory str1, uint256 i) public pure returns (string memory result) {
        return string(abi.encodePacked(str1, i.toString()));
    }

    /// @notice Concat number and string
    /// @param i Number to concat
    /// @param str String to concat
    /// @return result Concatenated string and number
    function prependNumber(uint256 i, string memory str) public pure returns (string memory result) {
        return string(abi.encodePacked(i.toString(), str));
    }
}
