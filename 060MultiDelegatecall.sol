// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;


//  多重委托调用
// 委托自己多次调用函数
contract MultiDelegateCall{
    error DelegateCallFailed();
    function multiDelegatecall(bytes[] calldata data)
        external 
        payable 
        returns(bytes[] memory results)
    {
        // 返回值的数组长度和参数中数组长度要相同 
        results = new bytes[](data.length);
        for (uint i; i< data.length;i++){
            // 用当前合约的地址，进行委托 调用，委托调用不能应用在其他的合约上，只能针对自己的合约进行委托调用，因为委托调用不能修改被调用合约的任何状态变量，只能修改委托合约自己的状态变量
            // 调用是否成功，
            (bool ok ,bytes memory res) = address(this).delegatecall(data[i]);
            if (!ok){
                revert DelegateCallFailed();
            }
            results[i] = res;
        }
    }
}

//  2个函数，一个有参数，一个没参数，都发送一个Log时间，向链外汇报当前调用者和一些参数
// 这个调用者在上节课中讲到的多重调用的情况下，会体现出多重调用合约，而不是当前真是的调用者，所以可以使用多重委托调用
// alice 使用多重调用合约 ---> Multicall 调用 -->TestMultiDelegatecall 合约，这里的msg.sender = Multicall合约, 因为msg.sender 只能看到上一个调用者
// 如果你需要通过这个合约来获取自己（alice）的信息，就可以使用delegate委托调用的方法

// alice(钱包1地址) ---> 调用委托合约 DelegateCall  -->  再调用TestMultiDelegatecall合约,  这时候的msg.sender =Alice 自己的合约

// 委托调用合约继承到我们的合约中，
// 注意：委托调用合约不能单独存在，就像多重调用合约一样，用他可以调用其他的合约，委托调用只能调用自身合约，因此这里存在一个限制，合约不是自己编写的，我们也无法使用委托调用
contract TestMultiDelegateCall is MultiDelegateCall{
    event Log(address caller,string func ,uint i);

    function func1(uint x, uint y) external {
        emit Log(msg.sender, "func1", x+y);

    }

    function func2() external returns(uint z){
        emit Log(msg.sender, "func2", 2);
        z = 111;
    } 
    mapping (address => uint ) public balanceOf;
    function mint()external  payable {
        balanceOf[msg.sender] += msg.value;
    }

}

contract Helper{
// 和多重调用一样，我们多次调用 func1 和 func2 是要拿到两个函数的data，也就是机器码，通过一个Helper合约来实现
    function getFunc1Data(uint x, uint y) external pure returns(bytes memory data) {
        data = abi.encodeWithSelector(TestMultiDelegateCall.func1.selector, x, y);

    }

    function getFunc2Data() external pure returns(bytes memory data) {
        data = abi.encodeWithSelector(TestMultiDelegateCall.func2.selector);

    }

    function getMintData() external pure returns(bytes memory data){
        data = abi.encodeWithSelector(TestMultiDelegateCall.mint.selector);
    }
}

/*
部署测试，部署Helper、 Test合约，输入 1,2 拿到两个函数的机器码
组合一下 multiDelegateCall 方法的参数
["0x3cb8008500000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000002","0xb1ade4db"]

打开日志看下Log日志事件
emit Log(msg.sender, "func1", x+y); func1 方法里面的 msg.sender 就是我们当前钱包的默认账户  0x5B38Da6a701c568545dCfcB03FcB875f56beddC4
下面的func2 同理

这样用默认账户委托多重调用成功了

再强调：：：： 多重委托调用只能调用合约自身，可以把多重委托调用合约制作成抽象合约，被自己的合约继承下来

*/



/*
多重委托合约可能会为合约带来一定的漏洞
重新部署合约，获取铸造 mint 方法的data，然后重复调用3次 mint方法, 并发送 1 ETH
["0x1249c58b","0x1249c58b","0x1249c58b"]

检查调用者地址的balanceOf，按照逻辑调用三次，会给当前调用者的地址上 有3 ETH，
3000000000000000000
明显是错误的，因为我们只发送了 1 ETH
这就是因为多重委托调用重复调用的时候，在合约中用 msg.value 给 msg.sender 增加了三次主币的数量，这样的逻辑就有错误
因此合约逻辑中，不要重复计算主币数量；或者多重委托调用方法不能接收主币也是一种解决方案。


*/




