
// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

contract Immutable{
    // 定义一个owner，想在合约部署的时候进行初始化
    // 合约部署完成之后就不希望在进行改变了，类似于常量一样
    // 加上之后会节省一些gas
    address public immutable owner ;

    constructor(){
         owner = msg.sender;
    }
    uint public x;
    function foo()external {
        require(msg.sender == owner);
        x+=1;
    }

}
// 去掉immutable  	52562 gas
// 加上immutable  	50111 gas