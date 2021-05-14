// SPDX-License-Identifier: MIT


pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";

/// @title Simulation of the "King of the Hill" game
/// @author Panos
/// @notice The game ends with the last failing attempt. 
/// @notice Contract uses `block.number` and doesn't work with Javascript VM 

/// @dev Network: Rinkeby
/// @dev Contract address: 0x58e5D09b6Cea2D6DC4e4EA1E6090D52E47BE19a3

contract KingGame {

    // @param _potOwner The current owner of the pot (the person who doubled the pot money)
    // @param _king The final owner of the pot (bobody topped him after )
    // @param _contractOwner The owner of the contract
    // @param _blockFlag A flag used for timestamp 
    // @param _maxBlocks The span of blocks until Game Over
    // @param _potTotal The total ether resting in the contract
    // @param _gameOver True if the game is over 

    address private _potOwner ;
    address private _king ;
    address private _contractOwner ;
    mapping (address => uint256) private _balances; 
    uint private _blockFlag;
    uint private _maxBlocks;
    uint private _potTotal;
    bool private _gameOver; 
    
    
    
    
    event NextPotOwner (address indexed sender, uint256 amount);
    event Deposited (address indexed sender, uint256 amount);
    event GameOver (address indexed king);
    event ResetGame(uint256 _blockFlag);

    using Address for address payable; 

    
    constructor (uint maxBlocks_) payable {
        _contractOwner = msg.sender; 
        _potOwner = _contractOwner; 
        _potTotal += msg.value; // initial pot money by contract owner
        _maxBlocks = maxBlocks_ ; // can't change during the game 
        _blockFlag = block.number; 

    }


    modifier onlyOwner() {
        require(
            msg.sender == _contractOwner, 
            "Ownable: Only owner can call this function");
        _;
    }
    
    
    modifier resetRules() {
        require(
            _gameOver, 
            "Game: The game is not over, you can't reset"
        );
        _;
    }
    

    
    function Play() public payable {
        
        if (_gameOver || msg.value < 2 * _potTotal) {
                                
                _withdraw(msg.sender, msg.value);  // return back the money
                _checkGameOver(); // this will set gameOver true, if it's too late
                
                
                if (_gameOver) {
                    _king = _potOwner; 
                    _endGame();
                } 
                
        } else {
            _potOwner = msg.sender; // he's potOwner until another one gets the title
            _deposit(msg.sender, msg.value);
            _blockFlag = block.number; 
            emit NextPotOwner (_potOwner, msg.value);

        }
        
    }
    
    function _withdraw(address to, uint256 amount) public {
        payable(to).sendValue(amount);
    }
    
    
    function _checkGameOver() public {
        _gameOver = (block.number - _blockFlag) >  _maxBlocks? true: false; 

    }


    function gameReset() public onlyOwner resetRules {
        _gameOver = false; 
        _blockFlag = block.number; 
         emit ResetGame(_blockFlag);


    }


    function _deposit(address sender, uint256 amount) internal {
        _potTotal += amount;
        emit Deposited(sender, amount);
    }

    function _endGame() private {

        uint kingPart = (_potTotal*8)/10;
        _potTotal -= kingPart; 
        _withdraw(_king, kingPart);

        uint ownerPart = (_potTotal*1)/10;
        _potTotal -= ownerPart; 
        _withdraw(_contractOwner, ownerPart);
        
        
        
    }
    
    
    function getGameOver() public view returns(bool) {
        return _gameOver; 
    }
    

    function getPotTotal() public view returns(uint) {
        return _potTotal;
    }
    
    
        
    function getContractBalance() public view returns(uint) {
        return address(this).balance;
    }

    function getPotOWner() public view returns(address) {
        return _potOwner;
    }

    function getBlockFlag() public view returns(uint) {
      return _blockFlag; 
    }

    function getCurrentBlockNumber() public view returns(uint) {
      return block.number; 
    }
    
    function getKing() public view returns(address) {
      return _king; 
    }



}