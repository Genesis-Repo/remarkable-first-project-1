// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract DecentralizedExchange {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    address public admin;
    mapping(address => mapping(address => uint256)) public balances;
    mapping(address => uint256) public poolBalances;

    event Deposit(address indexed token, address indexed user, uint256 amount);
    event Withdraw(address indexed token, address indexed user, uint256 amount);
    event Trade(address indexed tokenGive, uint256 amountGive, address indexed tokenGet, uint256 amountGet);
    event AddLiquidity(address indexed token, uint256 amount);
    event RemoveLiquidity(address indexed token, uint256 amount);

    constructor() {
        admin = msg.sender;
    }

    function deposit(address _token, uint256 _amount) external {
        IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
        balances[_token][msg.sender] = balances[_token][msg.sender].add(_amount);
        emit Deposit(_token, msg.sender, _amount);
    }

    function withdraw(address _token, uint256 _amount) external {
        require(balances[_token][msg.sender] >= _amount, "Insufficient balance");
        
        balances[_token][msg.sender] = balances[_token][msg.sender].sub(_amount);
        IERC20(_token).safeTransfer(msg.sender, _amount);
        emit Withdraw(_token, msg.sender, _amount);
    }
    
    function trade(address _tokenGive, uint256 _amountGive, address _tokenGet, uint256 _amountGet) external {
        require(balances[_tokenGet][msg.sender] >= _amountGet, "Insufficient balance");
        require(balances[_tokenGive][msg.sender] >= _amountGive, "Insufficient balance");
        
        balances[_tokenGive][msg.sender] = balances[_tokenGive][msg.sender].sub(_amountGive);
        balances[_tokenGet][msg.sender] = balances[_tokenGet][msg.sender].add(_amountGet);
        
        emit Trade(_tokenGive, _amountGive, _tokenGet, _amountGet);
    }

    function addLiquidity(address _token, uint256 _amount) external {
        IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
        poolBalances[_token] = poolBalances[_token].add(_amount);
        emit AddLiquidity(_token, _amount);
    }

    function removeLiquidity(address _token, uint256 _amount) external {
        require(poolBalances[_token] >= _amount, "Insufficient liquidity in the pool");
        
        poolBalances[_token] = poolBalances[_token].sub(_amount);
        IERC20(_token).safeTransfer(msg.sender, _amount);
        emit RemoveLiquidity(_token, _amount);
    }
}