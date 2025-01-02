
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/*
solidity 允许合约调用其他的合约，但是有的时候我们没有合约的具体实现代码，这时候就可以使用接口来调用其他的合约，不需要知道每个合约的具体实现方法
*/

// contract Counter{
//     uint public count;
//     function increment() external {
//         count +=1;
//     }
// }
// 假设Counter 合约的代码很长，我们没有具体的合约，就可以通过接口来实现调用
interface ICounter{
    // 定义函数的签名，不需要{} 函数结构体，因为不需要接口里面实现
    function count() external view returns(uint);
    function increment()external ;
}
contract MyContract{
    function incrementCounter(address _counterAddr) external{
        ICounter(_counterAddr).increment();
    }
    function getCount(address _counter) external view returns(uint){
        return ICounter(_counter).count();
    }
}


