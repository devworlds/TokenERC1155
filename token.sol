// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract Stonoex is ERC1155 {

    //Properties
    uint256 public constant GOLD = 0;
    uint256 public constant SILVER = 1;
    address public MasterOwner;
    mapping(address => bool) public TokenOwners; 

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


    //Public Functions
    function setTokenOwner(address newAddress) public isMasterOwner {
        TokenOwners[newAddress] = true;
    }

    function deleteTokenOwner(address newAddress) public isMasterOwner {
        TokenOwners[newAddress] = false;
    }

    function mint(address mintAddress, uint256 id, uint256 amount) public isTokenOwner{
        _mint(mintAddress, id, amount, '');
    }

    function burn(address burnaddress, uint256 id, uint256 amount) public isTokenOwner{
        _burn(burnaddress, id, amount);
    }

    function transfer(address to, uint256 amount, uint256 id) public {
        uint256 fee;
        fee = amount/100*3;
        amount -= fee;
        safeTransferFrom(msg.sender, to, id, amount, '');
        safeTransferFrom(msg.sender, MasterOwner, id, fee, '');
    }

    //Private functions
    function hasTokenOwner(address owneraddress) private view returns(bool){
        return TokenOwners[owneraddress];
    }

}