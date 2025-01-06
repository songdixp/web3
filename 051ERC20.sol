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
        // 发送方法的基本逻辑，在发送者的账户中 - 掉数量，在接收者的账户中 + 相应的数量，操作的就是balanceOf，ERC20 的核心账本 
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount); // 在链外进行统计的时候，就能统计出来整个的token的流转数量了
        return true; // 返回true就可以了，如果前发生了数学溢出，就无法执行到这一步
    }

    // 批准的方法
    function approve(address spender , uint256 amount) external   returns(bool){
        // 修改批准映射，找到当前合约的调用者，spender 就是被授权账户，你可以设置一定的数量
        // 也可以设置成为0，相当与取消他的授权
        // 批准额度完成之后，就可以在allowance中查询到批准的数量了
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom (
        address sender ,
        address recipient, 
        uint256 amount
    ) external returns(bool){
            // 函数调用者就是被批准额度的账户，发送者就是批准额度中的调用者 
            allowance[sender][msg.sender]-=amount; // 给被批准额度的账户中的额度 减掉相应数量
            balanceOf[sender] -=amount;//从发送者的账户中减掉余额，而不是消息调用者的余额中减掉，因为调用者只是一个执行者的身份
            balanceOf[recipient]+=amount;
            emit Transfer(sender, recipient, amount);
            return true;
        }

    // 还需要考虑一个问题，部署合约之后没有任何人的账户中有余额，因此就要想办法给账户增加余额
    // 通常情况下，ERC20 在部署的时候通过构造函数，把指定的数量余额赋值给当前合约的部署者，为了简单的演示，就编写铸币方法
    function mint(uint amount)external {
        // 给一个账户增加余额
        // 通常铸币方法要有权限的控制，但是为了演示方便，我们降低难度，就不增加权限控制功能了
        balanceOf[msg.sender] += amount;
        totalSupply += amount; // 合约持有的token总量也要发生变化
        // 当在区块链浏览器上看到0地址发出来的token，不是从黑洞中发出来的，而是铸币事件
        emit Transfer(address(0), msg.sender, amount);
    }

    // 还需要销毁方法
    function burn(uint amount) external {
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);

    }
    
}

