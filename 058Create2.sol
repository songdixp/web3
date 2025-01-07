

// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;


// 继续讲解通过合约部署合约的方法，create2方法前面讲解过，今天再详细介绍一下
// 之前通过工厂合约部署其他合约，是通过工厂合约的地址和工程合约对外发出交易的nonce值，计算出来的新合约的地址 
// create2方法是用工厂合约的地址加上 盐 ，来计算新的合约的部署地址，所以新部署合约的地址在部署之前就能预测出来
contract DeployWithCreate2{
    address public owner;

    constructor(address _owner){
        owner = _owner;
    }
}


contract Create2Factory{
    event Deploy(address addr);

    function deploy(uint _salt)external {
        // 用工厂合约来部署其他合约
        // DeployWithCreate2 _contract = new DeployWithCreate2(msg.sender);
        // create2方法是如何部署合约的？
        DeployWithCreate2 _contract = new DeployWithCreate2{
            salt: bytes32(_salt) // 输入一个数字
        }(msg.sender);
        emit  Deploy(address(_contract)); // 向链外汇报部署的合约地址
    }

    // 写预测地址的方法
    // 通过工厂合约的地址+盐+被部署的合约的bytecode（机器码）就能计算出来部署新合约的地址
    // 工厂合约、新部署的合约也不变、盐也不变，新部署的合约地址就不变，相同的盐只能使用一次，否则就会发生重复部署合约的错误
    // 如果新合约会有自毁功能的，相同的盐还可以再部署在原来的地址上

    // 计算地址
    function getAddress(bytes memory bytecode ,uint _salt)public view returns(address){
        // 整体逻辑就是计算hash值
        // 运算新合约地址就是得到一个hash值，还要转成uint160类型（地址标准格式）
        // 计算新地址的值，只有salt可以变化，其他的值都不能变化，因此改变盐就能改变未来新部署合约的地址
        bytes32 hash = keccak256(
            // 四个部分组成 1固定的字符串； 2 当前合约的地址；3 盐 ；4 针对合约源代码机器码的hash bytecode就是部署在链上的机器码；5 还要增加构造函数的参数
                abi.encodePacked(bytes1(0xff),address(this),_salt,keccak256(bytecode)
            )
        );
        return address(uint160(uint(hash)));
    }

    // 获取机器码，将构造函数的参数连在后面
    function getBytecode(address _owner) public pure returns(bytes memory){
        bytes memory bytecode = type(DeployWithCreate2).creationCode;
        // 在通过将机器码和构造函数参数打包到一起 返回bytecode
        return abi.encodePacked(bytecode, abi.encode(_owner));
    }
    
}
