// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract TestCall{
    // call是一个比较底层的方法，除了发送以太之外，还能调用其他合约的任意一个函数
    string public message;
    uint public x;

    event Log(address caller, uint amount, string message);

    // 定义revive 接受以太，且message.data 为空
    receive() external payable {}

    fallback() external payable { 
        emit Log(msg.sender,msg.value, "Fallback was called");
    }

    function foo (string memory _message, uint256 _x) public payable returns (bool, uint256){
        message = _message;
        x=_x;
        return (true,999);
    }

}

// 定义一个合约
contract Call{
    // 5 定义状态变量检查函数返回值是多少
    bytes public data;
    // 调用其他合约，需要传入对方合约的地址信息才能进行交互
    // 7合约方法加上payable之后才能传入以太给这个合约，也才能传入以太给TestCall合约
    function callFoo(address _testCalladdr)external payable {
        // 1有了合约地址之后，就能调用对方合约的方法，通过call 
        // 2call 方法是比较底层的函数，因此需要进行编码 abi.encodeWithSignature 签名字符串不能存在空格，uint需要协程uint256完整名称
        // 3返回值 除了bool 之外还有合约函数的返回值，之前说是不需要的
        // 4call的时候也可以发送以太，也可以控制gas, 调用方法之后会报错：If the transaction failed for not having enough gas, try increasing the gas limit gently.
        // 因为调用的foo函数修改了状态变量，5000gas不足 ，注意：调用的时候传入数量不要忘记，111wei
        (bool suc ,bytes memory _data) =  _testCalladdr.call{value:111}(abi.encodeWithSignature("foo(string,uint256)", "callFoo",123));
        require(suc,"callFoo failed");
        // 6返回成功之后，进行赋值
        data=_data;
        
    }    
    // 8调用其他合约中不存在的方法会怎样
    function callNotExistFunc(address _testCalladdr) external {
        (bool suc,) = _testCalladdr.call(abi.encodeWithSignature("callNotExist()"));
        require(suc,"not Exist!");


    }
}
