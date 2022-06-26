// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract Stonoex is ERC1155 {

    //Properties
    uint256 public constant GOLD = 1;
    uint256 public constant SILVER = 2;
    uint256 public constant COOPER = 3;
    uint256 public constant DIAMOND = 4;

    address public MasterOwner;
    uint256 public feeValue = 3;
    mapping(address => bool) public TokenOwners; 
    mapping(uint => address) public TokenMintID;

    //Constructor
    constructor() ERC1155("https://game.example/api/item/{id}.json") {
       MasterOwner = msg.sender;
    }

    //Modifiers
    modifier isMasterOwner(){
        require(MasterOwner == msg.sender, "Only MasterOwner can do this.");
        _;
    }

    modifier isTokenOwner(){
        require(hasTokenOwner(msg.sender) == true, "Only TokenOwner can do this.");
        _;
    }

    //Events
    event SetMasterOwner(address newMasterOwner);
    event SetTokenOwner(address newTokenOwner);
    event DeleteTokenOwner(address delTokenOwner);


    //Public Functions
    function changeMasterOwner(address newMasterOwner) public isMasterOwner{
        MasterOwner = newMasterOwner;
        emit SetMasterOwner(newMasterOwner);
    }
    
    function setTokenOwner(address newAddress) public isMasterOwner {
        TokenOwners[newAddress] = true;
        emit SetTokenOwner(newAddress);
    }

    function deleteTokenOwner(address oldAddress) public isMasterOwner {
        TokenOwners[oldAddress] = false;
        deleteTokenOwner(oldAddress);
    }

    function mint(address mintAddress, uint256 id, uint256 amount) public isTokenOwner{

        if(TokenMintID[id] == 0x0000000000000000000000000000000000000000){
            _mint(mintAddress, id, amount, '');
            TokenMintID[id] = msg.sender;
        }

        require(TokenMintID[id] != 0x0000000000000000000000000000000000000000);
        require(TokenMintID[id] == msg.sender, "Token already has an owner!");
        _mint(mintAddress, id, amount, '');
        TokenMintID[id] = msg.sender;
    }

    function getOwnerMint(uint id) public view returns(address){
        return TokenMintID[id];
    }

    function burn(address burnaddress, uint256 id, uint256 amount) public isTokenOwner{
        require(TokenMintID[id] == msg.sender, "Only owner of this token can burn it!");
        _burn(burnaddress, id, amount);
    }

    function transfer(address to, uint256 amount, uint256 id) public {
        uint256 fee;
        
        fee = amount/100*feeValue;

        amount -= fee;
        safeTransferFrom(msg.sender, to, id, amount, '');
        safeTransferFrom(msg.sender, MasterOwner, id, fee, '');
    }

    function setFee(uint256 amount) public isMasterOwner{
        feeValue = amount;
    }

    //Private functions
    function hasTokenOwner(address owneraddress) private view returns(bool){
        return TokenOwners[owneraddress];
    }

}