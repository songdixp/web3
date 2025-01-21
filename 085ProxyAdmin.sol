

/*

1. 回顾与背景 
    • 之前的内容回顾：如何区分代理合约的管理员调⽤和普通⽤⼾调⽤。
    • 本次课程⽬标：编写⼀个Proxy Admin合约，该合约将作为代理合约的管理员。 
2. 问题描述 
    • 当前问题：管理员调⽤代理合约中的admin或implementation函数时会冲突，因为这些函数在代理合约和实现合约中都存在。
    • 解决⽅案：创建Proxy Admin合约，管理代理合约的调⽤权限。 
3. 编写Proxy Admin合约 
    • 定义合约和构造函数
        ◦ 创建Proxy Admin合约并设置所有者（合约的部署者）。 
    • onlyOwner修饰符 
        ◦ 定义onlyOwner修饰符，确保只有所有者能执⾏某些函数。 
    • changeProxyAdmin函数 
        ◦ 定义函数changeProxyAdmin，改变代理合约的管理员。 
    • upgrade函数 
        ◦ 定义函数upgrade，升级代理合约中的实现合约。 
4. 设置和调⽤函数 
    • 更改管理员
        ◦ 定义函数changeAdmin，更改代理合约的管理员。 
    • 静态调⽤函数
        ◦ 使⽤静态调⽤获取代理合约的管理员和实现合约地址（getProxyAdmin和 getProxyImplementation）。 
5. 部署与测试 
    • 部署合约
        ◦ 部署CounterV1、CounterV2、Proxy和Proxy Admin合约。 
    • 测试合约
        ◦ 测试更改代理合约的管理员和实现合约地址。
        ◦ 测试CounterV1和CounterV2的功能，实现升级。 
6. 总结与练习 
    • 总结本次课程内容。
    • 练习：编写⼀个简单的代理合约并实现升级功能。

编程作业 
编写⼀个简单的代理合约，并实现如下功能：
1. 定义⼀个合约 SimpleProxy ，包含⼀个管理员地址和⼀个实现合约地址。
2. 定义函数 changeAdmin 和 upgradeImplementation ，实现更改管理员和升级实现合约的功能。
3. 部署并测试合约，确保能够正确更改管理员和升级实现合约。

*/ 