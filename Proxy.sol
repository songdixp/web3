// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
// 部署任何合约

// 合约1
contract TestContract1{
    
    address public owner = msg.sender;

    function setOwner(address _owner) public {
        require(msg.sender == owner, "not owner");
        owner =_owner;
    }
}

// 合约2
contract TestContract2 {
    
    address public owner = msg.sender;
    uint256 public value = msg.value;
    uint256 public x;
    uint256 public y;

    constructor(uint256 _x, uint256 _y) payable {
        x = _x;
        y = _y;
    }
}

// 代理合约，通过调用deploy 函数可以部署其他的任何合约
contract Proxy{
    event Deploy(address); //类似于记录日志的功能,记录当前合约的地址
    // 只需要传入bytes类型的code 就能进行部署合约，不需要在函数体内指定函数的名称
    function deploy(bytes memory _code )
        external 
        payable  // 调用deploy的时候可以转ETH
        returns (address addr) //部署完成后返回地址
    {
        // address addr;
        // 为了部署任意的合约，需要使用到内联汇编的语法
        assembly{
            // create(v,p,n)
            // v 以太坊的数量
            // p 代码在内存中的起始指针pointer
            // n 代码的大小 size

            // 通常的写法eth的大小通常使用 msg.value 但是在汇编的语法里面是不争取的，汇编的写法：callValue()
            // p code的长度，但是前32字节代表了code的长度，所以需要跳过去
            // 最后需要输入code的长度，也就是code的前32位，使用mload加载
            // := 相当于 定义一个局部变量 address addr; 并且返回 addr；
            addr := create(callvalue(), add(_code, 0x20), mload(_code))
        }
        // return addr; 
        // 在返回addr之前需要检查 addr地址是不是 0
        require(addr !=address(0),"deploy failed");
        // 通过，就发送一个时间emit
        emit Deploy(addr);         
    }
    receive() external payable {}
    // 为了能让我们的代理合约能调用其他合约，还需要添加一个执行的函数。
    // _target 为调用的目标地址，向合约传递的数据 data 
    function execute(address _target, bytes memory _data) external payable {
        // 调用目标合约的时候可能会转一些ETH，因此合约还需要定义 receive方法，这样代理合约就可以接受以太
        (bool success, ) = _target.call{value:msg.value}(_data);
        require(success, "failed");
    }
}

// 在指定deploy 和execute 函数之前，需要先编写一个合约，来提取和拿到contract1 contract2的creation code制造函数,创造字节码
// 正常工作中可以通过web3.gs 或者 iss.gs拿到编译过后的合约字节码
// 注意contract2 里面有构造函数 x y 所以在拿到creationCode之后还要进行encode
// 最后我们想用代合约调用contract1的 setOwner的话 就需要构造getCallData
contract Helper{
    function getByteCode1() external pure returns (bytes memory){
        bytes memory byteCode = type(TestContract1).creationCode;
        return byteCode;
    }
    function getByteCode2(uint256 _x, uint256 _y) external pure returns (bytes memory){
        bytes memory byteCode = type(TestContract2).creationCode;
        return abi.encodePacked(byteCode, abi.encode(_x, _y));
    }
    function getCallData(address _owner)external pure returns(bytes memory){
        return abi.encodeWithSignature("setOwner(address)", _owner);
    }
}


