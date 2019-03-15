pragma solidity 0.5.5;

import "openzeppelin-solidity/contracts/token/ERC20/TokenTimelock.sol";
import "openzeppelin-solidity/contracts/token/ERC20/IERC20.sol";

/**
 * @title Token
 * @notice Fully-compliant ERC20 mintable token
 */

import "../Roles.sol";

contract MinterRole {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor () internal {
        _addMinter(msg.sender);
    }

    modifier onlyMinter() {
        require(isMinter(msg.sender));
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {
        _addMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(msg.sender);
    }

    function _addMinter(address account) internal {
        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {
        _minters.remove(account);
        emit MinterRemoved(account);
    }
}

 import "./ERC20.sol";

 /**
  * @title ERC20Mintable
  * @dev ERC20 minting logic
  */

contract ERC20Mintable is ERC20, MinterRole {
     /**
      * @dev Function to mint tokens
      * @param to The address that will receive the minted tokens.
      * @param value The amount of tokens to mint.
      * @return A boolean that indicates if the operation was successful.
      */
    function mint(address to, uint256 value) public onlyMinter returns (bool) {
        _mint(to, value);
        return true;
    }
}


contract Token is ERC20Mintable {

    string private constant _name = "Token";
    string private constant _symbol = "TKN";
    uint8 private constant _decimals = 18;

    constructor() public {
        uint8 base = 10;
        uint256 initialSupply = 1000 * (base ** _decimals);
        // The account creating the token receives the whole initial supply
        _mint(msg.sender, initialSupply);
    }

    function timelockTransfer(address beneficiary, uint amount, uint releaseTime) external {
        // Deploy timelock contract
        TokenTimelock newTimelock = new TokenTimelock(IERC20(address(this)), beneficiary, releaseTime);

        // Send tokens to timelock
        transfer(address(newTimelock), amount);
    }

    /**
     * Issue new tokens, but first keep them in a timelock contract for a specific period of time
     */
    function timelockMint(address beneficiary, uint256 amount, uint256 releaseTime) external {
        // Deploy timelock contract
        TokenTimelock newTimelock = new TokenTimelock(IERC20(address(this)), beneficiary, releaseTime);

        // Mint tokens to timelock
        _mint(address(newTimelock), amount);
    }

    function name() public view returns (string _name) {
        return _name;
    }

    function symbol() public view returns (string _symbol) {
        return _symbol;
    }

    function decimals() public view returns (uint8 _decimals) {
        return _decimals;
    }
}
