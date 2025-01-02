// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    // 查询某个地址的余额
    function balanceOf(address account)external view returns(uint256);
    // 把token打给某个接受者
    function transfer(address recipient,uint256 amount) external returns(bool);
    // token的拥有者，允许消费者花费的额度，返回允许的额度
    function allowance(address owner, address spender) external view returns(uint256);
    // 针对allowance而言，允许消费者花费多少钱，也就是授权
    function approve(address spender , uint256 amount) external returns(bool);
    // 针对有allowance情况下，将sender的钱包的钱，转给接收方，数量必须是允许的额度（<=allowance）
    function transferFrom (address sender ,address recipient, uint256 amount) external returns(bool);

}

contract ERC20 is IERC20{
    // totalSupply 和 balanceOf是通过状态变量实现
    uint public override totalSupply;
    mapping (address => uint) public override balanceOf;
    // 钱包地址，允许的调用者，调用的数量（额度）
    mapping (address => mapping(address => uint)) public override allowance;
    string public name = "Test";
    string public symbol = "Test";
    // 18位小数等于1ETH
    uint public decimals = 18;
 
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address  indexed spender, uint256 value);
    

    // 把调用者 msg.sender 打给 接收方 recipient
    function transfer(address recipient,uint amount) external override  returns(bool){
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender , uint256 amount) external override  returns(bool){
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom (address sender ,address recipient, uint256 amount) 
        external override
        returns(bool){
            // 通过任意一方调用，把sender的token打给接收方，前提就是sender允许了调用方的一个额度，
            allowance[sender][msg.sender]-=amount;
            balanceOf[sender] -=amount;
            balanceOf[recipient]+=amount;
            emit Transfer(sender, recipient, amount);
            return true;
        }
    
}

