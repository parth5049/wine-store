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
/**
 * @title WineStore
 * @dev This contract allows to store, retrive, verify and revoke wines.
 */
contract WineStore is Ownable {

    using SafeMath for uint256;

    string public symbol = "WINE";
    string public  name = "Wine Store";
    uint public numberOfWines = 0;

    struct WineUnit {
        string name;
        uint256 alcoholPct;
        string cellarName;
        string country;
        uint identifier;
        uint256 createdTime;
    }

    event WineAdded(bytes32 wine);
    event WineRevoked(bytes32 wineHash);

    mapping (bytes32 => WineUnit) wineStoreDB;

    /**
     * @dev Add new wine.
     */
    function addWine(string vName, uint256 vAlcoholPct, string vCellarName, string vCountry, uint vID, bytes32 wineHash) 
    payable external onlyOwner returns (bool) {

        uint256 vCreatedTime = block.timestamp;
        //bytes32 docHash = sha256(abi.encodePacked(vName,vAlcoholPct,vCellarName,vCountry,vID,vCreatedTime));
        
        wineStoreDB[wineHash].name = vName;
        wineStoreDB[wineHash].alcoholPct = vAlcoholPct;
        wineStoreDB[wineHash].cellarName = vCellarName;
        wineStoreDB[wineHash].country = vCountry;
        wineStoreDB[wineHash].identifier = vID;
        wineStoreDB[wineHash].createdTime = vCreatedTime;

        numberOfWines = numberOfWines.add(1 ether);
        emit WineAdded(wineHash);
        return true;
    }

    /**
     * @dev Verifies if wine is authentic by accepting its hash and returns wine details.
     */
    function verifyWine(bytes32 vHash) external view returns (string, uint256, string, string, uint, uint256) {
        WineUnit storage unit = wineStoreDB[vHash];
        return (unit.name, unit.alcoholPct, unit.cellarName, unit.country, unit.identifier, unit.createdTime);
    }

    /**
     * @dev Verifies if the wine is authentic and returns true/false.
     */
    function isValidWine(bytes32 vHash) external view returns (bool){
        WineUnit storage unit = wineStoreDB[vHash];
        if(unit.identifier<=uint(0)){
            return false;
        }else{
            return true;
        }
    }

    /**
     * @dev Removes wine from the system.
     */
    function revokeWine(bytes32 hash, uint vID) external onlyOwner returns (bool) {
        require(wineStoreDB[hash].identifier == vID);
        wineStoreDB[hash].identifier = 0;
        numberOfWines = numberOfWines.sub(1 ether);
        emit WineRevoked(hash);
        return true;
    }

    // ------------------------------------------------------------------------
    // Don't accept ETH
    // ------------------------------------------------------------------------
    function () public payable {
        revert();
    }
} 