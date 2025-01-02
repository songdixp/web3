
// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

// 当一个合约调用另一个合约的时候，发送的数据到底是什么样的
// 接收函数
contract Reciver{
    event Log(bytes data);

    function transfer(address _to, uint _amount)external {
        emit Log(msg.data);

    }
}

// 检查log日志信息
// "data": "0xa9059cbb0000000000000000000000005b38da6a701c568545dcfcb03fcb875f56beddc40000000000000000000000000000000000000000000000000000000000000001"

// 解释一下这段数据如何被编码的
// 0x a9059cbb  这一段是8位 16进制的字符串 4字节 每一位的16进制等于4位二进制，所以相当与每两位16进制位等于1字节；这部分就是function selector 也就是编码过后的transfer
// 0000000000000000000000005b38da6a701c568545dcfcb03fcb875f56beddc4  这部分是 入参 address
// 0000000000000000000000000000000000000000000000000000000000000001  入参 amount

// solidity 是如何编辑 selector 选择器的？是怎么知道函数就是这4个字节的
// 就是之前讲过的对 transfer(address _to, uint _amount) 进行hash 取前四字节
// 演示函数：输入的字符串不能包含空格： "transfer(address,uint256)"
// "0": "bytes4: 0xa9059cbb"
contract FunctionSelector{
    function getSelector(string calldata _x)external pure returns(bytes4){
        return bytes4(keccak256(bytes(_x)));
    }
}

// 函数签名：不是指私钥对我们函数签名，而是对函数名称和参数的签名的一个叫法



