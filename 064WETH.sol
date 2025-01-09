
// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

/*
1. WETH概念: WETH代表"包装的以太"，是⼀种将以太（ETH）包装为ERC20标准代币的⽅法。⽤⼾
存⼊ETH时，将铸造出对应的ERC20代币；⽤⼾提取时，相应的ERC20代币将被销毁。通常在DeFi项目里面使用
2. 合约简化: 使⽤WETH可以避免编写两个分离的合约（⼀个针对ETH，⼀个针对ERC20代币）。通过
交互WETH，任何⽀持ERC20的合约都可以间接⽀持ETH。
3. 代码实现:
- 导⼊ERC20合约（例如使⽤OpenZeppelin库）。
- 初始化构造函数，设置代币名称（WETH）、符号（WETH）和⼩数位（18）
- 定义存款和提款事件
- 实现存款功能：接受ETH并铸造相应的ERC20代币。
- 实现提款功能：⽤⼾指定⾦额，合约销毁对应的ERC20代币并返回ETH。
- 处理直接发送到合约的ETH：通过回退函数调⽤存款函数。

编程作业
•
任务:创建⼀个简单的Solidity合约，实现WETH功能。
•
要求:
a. 编写⼀个合约，包含初始化构造函数和ERC20代币标准必需的参数。
b. 实现⼀个存款函数，使其能接收ETH并铸造相等数量的ERC20代币。
c. 实现⼀个提款函数，允许⽤⼾销毁他们持有的ERC20代币并提取相应的ETH。
d. 在合约中加⼊适当的事件记录存款和提款操作。
•
附加挑战:添加⼀个回退函数，以处理合约直接接收ETH的情况，并⾃动触发存款功能。
*/ 

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract WETH is ERC20{

    event Deposit(address indexed account, uint amount);
    event Withdraw(address indexed account, uint amount);

    // 初始化构造函数
    constructor()ERC20("Wrapped ETH", "WETH"){}

    // 如果没有调用deposit存款方法，就会走fallback方法（回退）调用deposit
    fallback() external payable { 
        deposit();
    }

    function deposit() public payable {

        _mint(msg.sender, msg.value);
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint _amount)external payable {
        // 发送以太给 调用者
        _burn(msg.sender, _amount);
        payable (msg.sender).transfer(_amount);
        emit Withdraw(msg.sender, _amount);
    } 

}



