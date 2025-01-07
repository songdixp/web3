
// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;


// 委托调用
/*
传统调用
A  call B ,send 10 wei;
    B call C ,send 20 wei;

A -------> B ---------> C 
                        msg.sende = B
                        msg.value = 20wei
                        C合约改变状态变量，C的状态变量改变
                        发送给C的ETC也会留在C合约中

*/
/* 委托调用
A  call B ,send 100 wei;
    B delegatecall C 
A -------> B ---------> C 
                        msg.sende = A
                        msg.value = 100 wei  A发送过来
                        C合约改变状态变量，C 不能改变所有的状态变量
                        C合约就不能保存100 wei的主币，要保存在B合约中，B合约是可以改变状态变量的值
                        同时在B合约中也要有相同的状态变量值的布局
*/

// 测试合约中函数要被调用，三个状态变量要被改变
contract TestDelegateCall{
    uint public num;
    address public sender;
    uint public value;

    function setVars(uint _num) external payable {
        num = _num;
        sender = msg.sender;
        value =msg.value;
    }
}

contract DelegateCall{
    uint public num;
    address public sender;
    uint public value;

    function setVars(address _testAddr, uint _num) external payable {
        // 和低级call的写法相同 参数中要有下一个被调用合约的函数签名 "函数名称(参数类型)" 这就完成了函数的编码了
        // _testAddr.delegatecall(abi.encodeWithSignature("setVars(uint256)", _num));
        
        // 新的写法,同样也能应用到低级的call中, 使用selector  上一个合约的名字.函数名字.selector  就能找到这个函数的selector了，两种写法实现的效果相同
        // 这种写法能避免一定概率的写错，大小写的错误，标点符号的错误，类型的错误
        (bool success, bytes memory data) = _testAddr.delegatecall(abi.encodeWithSelector(TestDelegateCall.setVars.selector, _num));
        // bytes返回是调用之后的返回数据
        require(success, "delegatecall failed!");
        //  这种调用就可以让我们调用委托到下一个合约中，下一个合约中看到的 msg.value msg.sender 都是自己
    }
}

/*
部署测试
部署 1 TestDelegateCall   2  DelegateCall

填写委托合约 DelegateCall 的 setVars 方法的参数，看一下三个变量是在哪个合约中被修改了。
测试合约 TestDelegateCall 的地址，123， 发送100wei
检查Delegatecall 合约的 num sender value 变量

在看一下被调用的合约：TestDelegateCall 的变量
发现并没有因为委托合约的调用而改变变量的值，被调用的合约不能改变值，只能使用被调用合约的逻辑，来改变当前委托合约的状态变量
而且，当前委托合约中没有修改状态变量的逻辑，调用的 Test合约是存在改变状态变量的值的，但是改变的是当前委托合约的状态变量，没有远程改变调用合约的变量

这样的调用方式相当与，当前合约定义了和调用合约相同的变量，但是没有逻辑，逻辑都是调用合约中存在的，这样就是一种可升级合约的基本范式
*/

/*
被调用的合约中也存在相同的变量，还有意义定义这几个相同的变量吗？
有，被调用合约的变量，顺序、名称、类型，必须和委托合约完全一致
*/

