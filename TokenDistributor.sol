pragma solidity 0.5.5;

/**
 * @title TokenDistributor
 * @notice Contract for token distribution.
 * @dev For this contract to work properly, it should be sent tokens first.
 */

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


library SafeMath {
     /**
      * @dev Multiplies two unsigned integers, reverts on overflow.
      */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
         // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
         // benefit is lost if 'b' is also tested.
         // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

     /**
      * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
      */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
         // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
         // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

     /**
      * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
      */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

     /**
      * @dev Adds two unsigned integers, reverts on overflow.
      */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

     /**
      * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
      * reverts when dividing by zero.
      */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


contract TokenDistributor {
    using SafeMath for uint256;

    address private _owner;

    // Address of the token contract
    address private _tokenAddress;

    // Array to hold all addresses that will receive a payment
    address[] beneficiaries;

    // Total amount of tokens to distribute
    uint256 private _totalAmount;

    // Mapping to keep track of how many tokens each beneficiary will receive
    mapping (address => uint256) amountsByBeneficiary;

    modifier onlyOwner() {
        require(msg.sender == _owner);
        _;
    }

    /**
     * Constructor
     */
    constructor(address tokenAddress) public {
        require(tokenAddress != address(0));
        _tokenAddress = tokenAddress;
        _owner = msg.sender;
    }

    /**
     * Add the address of a beneficiary that will receive a certain amount of tokens.
     */
    function registerBeneficiary(address beneficiary, uint256 amount) onlyOwner external {
        require(amount > 0, "Amount must be greater than zero");

        _totalAmount += amount;
        beneficiaries.push(beneficiary);
        amountsByBeneficiary[beneficiary] += amount;
    }

    /**
     * Decrease, by the given amount, the number of tokens a beneficiary will receive.
     */
    function decreaseBenefit(address beneficiary, uint256 amount) public onlyOwner {
        require(amountsByBeneficiary[beneficiary] != 0, "Beneficiary does not exist");

        // Decrease total and beneficiary's amount
        _totalAmount -= amount;
        amountsByBeneficiary[beneficiary] -= amount;
    }

    function payAllBeneficiaries() external onlyOwner {
        for (uint8 index = 0; index < beneficiaries.length; index++) {
            _paySingleBeneficiary(beneficiaries[index]);
        }
    }

    /**
     * Private function to pay a single beneficiary
     */
    function _paySingleBeneficiary(address beneficiary) public {
        uint256 amount = amountsByBeneficiary[beneficiary];

        // Transfer tokens to beneficiary
        IERC20(_tokenAddress).transfer(beneficiary, amount);

        // Decrease total amount of tokens to be distributed
        _totalAmount -= amount;
    }

    // Getters

    function getNumberOfBeneficiaries() external view returns (uint256) {
        return beneficiaries.length;
    }

    function getAmount(address beneficiary) external view returns (uint256) {
        return amountsByBeneficiary[beneficiary];
    }

    function owner() external returns (address) {
        return _owner;
    }

    function tokenAddress() external returns (address) {
        return _tokenAddress;
    }

    function totalAmount() external view returns (uint256) {
        return _totalAmount;
    }
}
