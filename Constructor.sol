
// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

// 构造函数是一个特殊的函数在部署合约的时候调用一次
// 作用：主要初始化一些状态变量
contract Constructor{
    address public owner;
    uint public x;
    // 首先定义关键字 constructor ，然后在参数列表中定义要初始化的变量

    constructor(uint _x){
        // 大括号里面可以正常的编写我们要的代码
        // msg.sender 是部署合约的账号地址，将调用者的地址赋值给owner，就完成了状态变量的初始化
        owner = msg.sender;
        x = _x;
    }
    // 注意：constructor 和普通的函数不同，普通函数可以重复调用很多次，constructor只能在部署的时候，自动调用一次，之后就再也调用不了了。

}


