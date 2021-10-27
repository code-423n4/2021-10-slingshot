// SPDX-License-Identifier: AGPLv3
pragma solidity 0.8.7;

import "./Adminable.sol";
import "./module/ISlingshotModule.sol";

/// @title   Module Registry Contract
/// @author  DEXAG, Inc.
/// @notice  This contract provides the logic for querying, maintaining, and updating Slingshot modules.
/// @dev     When a new module is deployed, it must be registered. If the logic for a particular
///          DEX/AMM changes, a new module must be deployed and registered.
contract ModuleRegistry is Adminable {
    /// @notice This is an index which indicates the validity of a module
    mapping(address => bool) public modulesIndex;

    /// @notice Slingshot.sol address
    address public slingshot;

    event ModuleRegistered(address moduleAddress);
    event ModuleUnregistered(address moduleAddress);
    event NewSlingshot(address oldAddress, address newAddress);

    /// @param _admin Address to control admin functions
    constructor(address _admin) {
        _setupAdmin(_admin);
    }

    /// @notice Checks if given address is a module
    /// @param _moduleAddress Address of the module in question
    /// @return true if address is a module
    function isModule(address _moduleAddress) external view returns (bool) {
        return modulesIndex[_moduleAddress];
    }

    /// @param _moduleAddress Address of the module to register
    function registerSwapModule(address _moduleAddress) public onlyAdmin {
        require(!modulesIndex[_moduleAddress], "oops module already exists");
        require(ISlingshotModule(_moduleAddress).slingshotPing(), "not a module");

        modulesIndex[_moduleAddress] = true;
        emit ModuleRegistered(_moduleAddress);
    }

    /// @param _moduleAddresses Addresses of modules to register
    function registerSwapModuleBatch(address[] memory _moduleAddresses) external onlyAdmin {
        for (uint256 i = 0; i < _moduleAddresses.length; i++) {
            registerSwapModule(_moduleAddresses[i]);
        }
    }

    /// @param _moduleAddress Address of the module to unregister
    function unregisterSwapModule(address _moduleAddress) public onlyAdmin {
        require(modulesIndex[_moduleAddress], "module does not exist");

        delete modulesIndex[_moduleAddress];
        emit ModuleUnregistered(_moduleAddress);
    }

    /// @param _moduleAddresses Addresses of modules to unregister
    function unregisterSwapModuleBatch(address[] memory _moduleAddresses) external onlyAdmin {
        for (uint256 i = 0; i < _moduleAddresses.length; i++) {
            unregisterSwapModule(_moduleAddresses[i]);
        }
    }

    /// @param _slingshot Slingshot.sol address implementation
    function setSlingshot(address _slingshot) external onlyAdmin {
        require(_slingshot != address(0x0), "slingshot is empty");
        require(slingshot != _slingshot, "no changes to slingshot");

        address oldAddress = slingshot;
        slingshot = _slingshot;
        emit NewSlingshot(oldAddress, _slingshot);
    }
}
