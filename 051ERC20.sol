// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

// 什么样的合约代表标准ERC20合约?
// ERC20的标准只包含了接口，就是实现了IERC20的接口的合约，就满足了标准。至于每个方法的实现是你自己的事情
// 例如：标准中并不会要求发送方法，是有发送者的账户中减少数量，接受者的账户中增加数量，这样的逻辑不是标准，不一定要这样实现
// 如果你的逻辑是发送者的账户数量不减少，只给接收者的账户增加数量，也是满足ERC20 的标准。
interface IERC20 {
    // 代表当前合约的token总量
    function totalSupply() external view returns (uint256);
    // 某个账户的当前余额
    function balanceOf(address account)external view returns(uint256);

    // 把账户中的余额，由当前调用者发送到另外一个账户，transfer是写入方法，还会向链外汇报Transfer事件，就能查看到token的流转了
    function transfer(address recipient,uint256 amount) external returns(bool);
    // 把我账户中的数量，批准给另一个账户，transfer方法和approve方法联合使用
    function approve(address spender , uint256 amount) external returns(bool);

    // 查询某一个账户对另一个账户批准额度有多少
    function allowance(address owner, address spender) external view returns(uint256);

    // 针对有allowance情况下，向另一个合约存款的时候，另一个合约必须要调用transferFrom方法才能把我们的token，拿到他的合约中
    function transferFrom (address sender ,address recipient, uint256 amount) external returns(bool);

}

// 要实现IERC20接口列出的所有接口
contract ERC20 is IERC20{
    // totalSupply 和 balanceOf是通过状态变量实现
    // 表名当前的token的总量，因为有public的可见范围，这样就默认实现了totalSupply函数
    uint public  totalSupply;
    // 定义映射，地址=》数字，就能组成账本，是ERC20合约的核心
    mapping (address => uint) public  balanceOf;
    // 定义批准的映射，地址=地址=数字，{发送者:{被批准者地址: 批准数量}}
    mapping (address => mapping(address => uint)) public  allowance;
    // 定义ERC20 合约token的名称
    string public name = "Test";
    // token的缩写，也就是符号，一般常用大写
    string public symbol = "TEST";
    // token的精度，常用的是18位精度，一个整数 1 后面有18个0的小数，智能合约中记录的数字只能有整数不能有小数点
    // 0.5的token如何记录 5+17个0， 1+18个0代表整数1
    uint8 public decimals = 18;
    // 以上是ERC20的所有变量
 
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address  indexed spender, uint256 value);
    

    // 把调用者 msg.sender 打给 接收方 recipient
    function transfer(address recipient,uint amount) external   returns(bool){
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender , uint256 amount) external   returns(bool){
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom (address sender ,address recipient, uint256 amount) 
        external 
        returns(bool){
            // 通过任意一方调用，把sender的token打给接收方，前提就是sender允许了调用方的一个额度，
            allowance[sender][msg.sender]-=amount;
            balanceOf[sender] -=amount;
            balanceOf[recipient]+=amount;
            emit Transfer(sender, recipient, amount);
            return true;
        }
    
}

