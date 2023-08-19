// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LoyaltyToken is ERC20, Ownable  {
    uint256 public totalTokensIssued;
    mapping(address => uint256) public userTokenBalances;

    event TokensEarned(address indexed user, uint256 amount);
    event TokensRedeemed(address indexed user, uint256 amount);

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _initialSupply
    ) ERC20(_name, _symbol) {
        _mint(msg.sender, _initialSupply);
    }

    function earnTokens(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        _mint(msg.sender, _amount);
        userTokenBalances[msg.sender] += _amount;
        totalTokensIssued += _amount;
        emit TokensEarned(msg.sender, _amount);
    }

    function redeemTokens(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        require(userTokenBalances[msg.sender] >= _amount, "Insufficient balance");
        _burn(msg.sender, _amount);
        userTokenBalances[msg.sender] -= _amount;
        emit TokensRedeemed(msg.sender, _amount);
    }

    function getBalance(address _user) external view returns (uint256) {
        return userTokenBalances[_user];
    }
}

contract LoyaltyProgram is Ownable {
    LoyaltyToken public tokenContract;
    uint256 public tokenValue;
    uint256 public tokenDecayPeriod;

    mapping(address => uint256) public earnedTokens;

    constructor(
        address _tokenContract,
        uint256 _tokenValue,
        uint256 _tokenDecayPeriod
    ) {
        tokenContract = LoyaltyToken(_tokenContract);
        tokenValue = _tokenValue;
        tokenDecayPeriod = _tokenDecayPeriod;
    }

    function setTokenValue(uint256 _newTokenValue) external onlyOwner {
        tokenValue = _newTokenValue;
    }

    function setTokenDecayPeriod(uint256 _newDecayPeriod) external onlyOwner {
        tokenDecayPeriod = _newDecayPeriod;
    }

    function issueTokens(address _user, uint256 _amount) external onlyOwner {
        earnedTokens[_user] += _amount;
        tokenContract.earnTokens(_amount);
    }

    function redeemTokens(uint256 _amount) external {
        require(earnedTokens[msg.sender] >= _amount, "Insufficient earned tokens");
        earnedTokens[msg.sender] -= _amount;
        tokenContract.redeemTokens(_amount);
    }
}
