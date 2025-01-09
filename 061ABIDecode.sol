// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

/*
abi 解码
前面多重调用的时候，制作过函数调用方法的编码格式，函数返回一些数据之后如何针对返回的数据进行解码？


*/

contract AbiCode{
    struct MyStruct{
        string name;
        uint[2] nums;
    }

    // 先进行编码
    function encode(
        // 尽量将输入做的复杂一些
        address addr,
        uint x,
        uint[] calldata arr,
        MyStruct calldata myStruct
    )external pure returns(bytes memory){
        // 编码形式就是将输入的所有类型进行encode 不带packed 有补0的效果
        return abi.encode(addr, x, arr, myStruct);
    }
    // 再进行解码
    function decode(bytes calldata data) external pure returns (
        // 解码要返回和编码参数一样的参数
        address addr,
        uint x, 
        uint[] memory arr,
        MyStruct memory myStruct
    ){
        // 你要针对编码后的数据进行解码，必须要知道解码的数据格式
        // 解码之后的数据按照返回类型的顺序进行返回
        // 返回结果也会按照解码之后的返回顺序进行返回，这里只需要写返回的变量，就能得到变量的值，使用 隐式返回把变量的值返回到外部
        (addr, x, arr, myStruct) = abi.decode( data, (address, uint , uint[], MyStruct));
    }
}
/*
部署encode之后
结构体的变量提示是元组，实际上是高纬度的数组，仍然使用[] 来进行
["Solidity", [1,2]] 注意定长数组
将编码之后的机器码，放到decode解码里面编译解析，就能顺里的解开编码格式
注意，结构体，元祖类型
3:tuple(string,uint256[2]): myStruct Solidity,1,2  元组类型是什么
这里我们输入的字符串在remix里面无法显示，但是你可以使用web3 或者ethers将结果返回出来
*/ 


