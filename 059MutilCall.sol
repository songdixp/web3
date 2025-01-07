// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;


// 多重呼叫解决方案
// 对一个合约或者多个合约的多次调用，打包在一个交易里面，对合约在进行调用
// 好处：在同一个网站的前端页面中对合约进行几十次调用，而一个链的RPC节点又限制了每个client对链的调用，20s之内只能调用一次
// 所以要把多个合约的读取的调用打包在一次，成为一次调用，这样就可以一次把想要的数据都读取出来了 
// 调用func1 func2 函数都返回当前时间戳，但是网络传输+节点限制，返回的第二个时间戳就可能和第一个时间戳不一致
// 如果要获取两个函数在同一个区块中的状态时，两次调用就无法获取在同一个区块中的状态了。
// 因此需要mutilcall合约，打包整合在一起，在一次调用中完成
contract TestMutilCall{
    function func1()external view returns(uint, uint){
        return (1, block.timestamp);
    }

    function func2()external view returns(uint, uint){
        return (2, block.timestamp);
    }

    // 获取函数1 的data
    function getData1()external pure returns (bytes memory){
        // 等价于 abi.encodeWithSignature("func1()");
        return abi.encodeWithSelector(this.func1.selector);

    }
    // 获取函数2 的data
    function getData2()external pure returns (bytes memory){
        // 等价于 abi.encodeWithSignature("func1()");
        return abi.encodeWithSelector(this.func2.selector);

    }
}


contract MutilCall{
    // 1参数 多次调用的合约地址，2 两次调用对合约发出的数据
    function mutilCall (address[] calldata targets, bytes[] calldata data)
        external 
        view 
        returns(bytes[] memory)
    {
        // 1首先判断输入参数两个长度是否一致，
        require(targets.length == data.length, "targets.length() != data.length()");
        bytes[] memory results = new bytes[](data.length);
        for (uint i;i<targets.length;i++){
            // 这里用地址的静态调用，用底层call会存在动态写入方法，函数定义式view只读，否在会报错
            (bool success, bytes memory result) = targets[i].staticcall(data[i]);
            require(success, "call failed");
            results[i] = result;
        }
        return results;
    } 
    // 问题2：传入的参数如何编写？
    // 传入的参数有data数据，调用1、2函数时区块链上真实发送的交易的input数据，如何得到？编写函数的方式来获取
    // 链外，可以通过ethers或者web3 这样的sdk工具编写脚本来获取
}

// 部署测试
// 部署好第一个测试合约，获取到函数的data，传给第二个合约
// multiCall 合约中第一个参数地址的数组，两次调用都是同一个地址的合约，把合约地址粘贴两次
// 返回值：bytes[]:  abi编码格式，后面会讲到如何解码
// 0x0000000000000000000000000000000000000000000000000000000000000001  前面是返回的1 00000000000000000000000000000000000000000000000000000000677cfb1a,这个是时间戳
// 0x0000000000000000000000000000000000000000000000000000000000000002  前面返回的事2 00000000000000000000000000000000000000000000000000000000677cfb1a，这个是时间戳发现时间戳是一致的
// 证明了是在相同的区块调用的



