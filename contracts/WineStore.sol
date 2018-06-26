pragma solidity ^0.4.18;

import "../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol";

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
    constructor() public {
        owner = msg.sender;
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and assisted
// token transfers
// ----------------------------------------------------------------------------
contract WineStore is Ownable {
    using SafeMath for uint256;
    string public symbol;
    string public  name;

    struct WineUnit {
        string name;
        uint256 alcoholPct;
        string cellarName;
        string country;
        uint8 identifier;
        uint256 createdTime;
    }

    event WineAdd(bytes32);

    mapping(bytes32 => WineUnit) wineStoreDB;
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor() public {
        symbol = "WINE";
        name = "Wine Store";
    }

    function addWine(string vName, uint256 vAlcoholPct, string vCellarName, string vCountry, uint8 vID) external onlyOwner returns (bytes32) {

        uint256 vCreatedTime = block.timestamp;
        WineUnit memory unit = WineUnit(vName,vAlcoholPct,vCellarName,vCountry,vID,vCreatedTime);
        bytes32 hash = sha256(abi.encodePacked(vName,vAlcoholPct,vCellarName,vCountry,vID,vCreatedTime));
        wineStoreDB[hash] = unit;
        emit WineAdd(hash);
        return hash;
    }

    function verifyWine(bytes32 vHash) external view returns (string, uint256, string, string, uint8, uint256) {
        WineUnit storage unit = wineStoreDB[vHash];
        return (unit.name, unit.alcoholPct, unit.cellarName, unit.country, unit.identifier, unit.createdTime);
    }

    function isValidWine(bytes32 vHash) external view returns (bool){
        WineUnit storage unit = wineStoreDB[vHash];
        if(unit.identifier<0){
            return false;
        }else{
            return true;
        }
    }

    // ------------------------------------------------------------------------
    // Don't accept ETH
    // ------------------------------------------------------------------------
    function () public payable {
        revert();
    }
}    