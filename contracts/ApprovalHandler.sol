// SPDX-License-Identifier: None
pragma solidity 0.8.7;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./Adminable.sol";

contract ApprovalHandler is Adminable {
    using SafeERC20 for IERC20;

    bytes32 public constant SLINGSHOT_CONTRACT_ROLE = keccak256("SLINGSHOT_CONTRACT_ROLE");

    modifier onlySlingshot() {
        require(isSlingshot(_msgSender()), "Adminable: not a SLINGSHOT_CONTRACT_ROLE");
        _;
    }

    constructor(address _admin) {
        // admin of the protocol, has great power
        _setupAdmin(_admin);
        // set _admin as an admin for SLINGSHOT_CONTRACT_ROLE
        _setRoleAdmin(SLINGSHOT_CONTRACT_ROLE, SLINGSHOT_ADMIN_ROLE);
    }

    /// @dev Convenience method to check if address has Slingshot contract role
    function isSlingshot(address _slingshot) public view returns (bool) {
        return hasRole(SLINGSHOT_CONTRACT_ROLE, _slingshot);
    }

    /// @dev Convenience method to add Slingshot contract role. `grantRole` is already
    ///      checking if msg.sender has an admin role so no need to guard this function
    function grantSlingshot(address _slingshot) external {
        grantRole(SLINGSHOT_CONTRACT_ROLE, _slingshot);
    }

    function transferFrom(address fromToken, address sender, address to, uint256 amount)
        external
        onlySlingshot
    {
        IERC20(fromToken).safeTransferFrom(sender, to, amount);
    }
}
