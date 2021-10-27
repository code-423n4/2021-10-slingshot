// SPDX-License-Identifier: AGPLv3
pragma solidity 0.8.7;
pragma abicoder v2;

import "@openzeppelin/contracts/access/AccessControl.sol";

 /// @title   Admin Role Contract
 /// @author  DEXAG, Inc.
 /// @notice  This contract is a utility for an admin role access.
abstract contract Adminable is AccessControl {
    bytes32 public constant SLINGSHOT_ADMIN_ROLE = keccak256("SLINGSHOT_ADMIN_ROLE");

    modifier onlyAdmin() {
        require(hasRole(SLINGSHOT_ADMIN_ROLE, _msgSender()), "Adminable: not a SLINGSHOT_ADMIN_ROLE");
        _;
    }

    /// @param _admin Setup admin role
    function _setupAdmin(address _admin) internal {
        _setRoleAdmin(SLINGSHOT_ADMIN_ROLE, SLINGSHOT_ADMIN_ROLE);
        _setupRole(SLINGSHOT_ADMIN_ROLE, _admin);
    }
}
