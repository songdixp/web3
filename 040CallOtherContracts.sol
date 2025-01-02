// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


contract Caller{
// 目的在caller里面调用另外一个合约
    function setx(address addr, uint _x) external {
        // 知道合约地址之后如何调用？ 先进行初始化,合约（合约的地址）.合约方法（方法入参）
        // 这样通过Caller合约的setX就完成了 TestContract合约的setX调用
        TestContract(addr).setX(_x);
    }
    // 第二种调用方式,合约名称写到入参的位置，这样就不用实例化，就知道 _addr就是TestContract合约
    function setX(TestContract _addr, uint _x) external {
        _addr.setX(_x);
    }
    // // 第一种写法
    // function getX(TestContract _addr)external  view returns (uint){
    //     return _addr.getX();
    // }
    // // 第二种写法
    // function getX(address _addr) external  view returns (uint){
    //     uint x = TestContract(_addr).getX();
    //     return x;
    // }
    // 第三种写法 省略了x的定义，直接在returns里面定义 也省略了return
    function getX(address _addr) external view returns(uint x){
        x = TestContract(_addr).getX(); 
    }
    
    // 如何调用另一个合约的方法，并且打ETH过去
    function setXandSendEther(address _addr, uint _x)external payable{
        // 如何发送以太? 在方法() 前加上{} 然后传入调用合约的msg.value
        TestContract(_addr).setXandSendEther{value:msg.value}(_x);
    }
    // // 如何调用多个返回值的方法
    // function getXandValue(address _addr)external view returns(uint, uint){
    //     return  TestContract(_addr).getXandValue();

    // }
    // 如何调用多个返回值的方法2
    function getXandValue(address _addr)external view returns(uint x, uint value){
        (x, value) = TestContract(_addr).getXandValue();
    }
}

contract TestContract{
    uint public x;
    uint public value = 123;

    function setX(uint _x)public returns(uint){
        x=_x;
        return x;
    }

    function getX()external view  returns(uint){
        return x;
    }

    function setXandSendEther(uint _x)public payable {
        x = _x;
        value =msg.value;
        
    }

    function getXandValue()external view returns(uint,uint){
        return(x, value); 
    }
}