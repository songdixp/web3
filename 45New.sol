

// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

// 合约部署合约，之前讲解了通过内联汇编的方式来部署合约
// 这次简单的，通过New语句来新建合约的方法
contract Account{
    address public bank;
    address public owner;
    constructor(address _owner)payable {
        owner = _owner;
        bank = msg.sender;

    }
}

contract AccountFactory{
    // 也可以创建账户合约的数组,工厂生产的产品是没有数量限制的
    Account[] public accounts;


    // 通过工厂合约来部署账户合约，相当于在工厂生产产品一样
    function createAccount(address _owner)external payable {
        // 参数对应的是合约的构造函数
        // 通过new语句创建合约，后面跟着合约的名字,因为账户合约和工厂合约在同一个文件，所以工厂合约是知道账户合约的源代码的
        // 不在同一个文件中， import 进来也是可以的
        // 用账户合约的名称当做类型，acount是变量，变量就记录了新创建的账户合约的地址
        // 因为账户合约的构造函数是 payable的，如何传递ETH？
        // 和之间讲解的call方法差不多, 在工厂合约的名称后面加上{}
        Account account = new Account{value:msg.value}(_owner);
        accounts.push(account);//在推送到工厂合约的数组中，这样就记录下来了每次工厂合约创建的地址

    }
}

// 测试，部署工厂合约，账户合约要通过工厂合约来进行部署，所以是不需要单独部署账户合约的
// 注意：工厂合约、账户合约要在一个文件里面，他们是引用的关系，不是继承关系，两个可以在一个文件中，不在一个文件中的话可以import导入进来
// 两个方法，一个写入，一个只读方法，写入可以传递 账户地址，并且 传递一定的value，部署成功之后，就创建出来一个新的账户合约
// 在只读变量里面输入0，也就是数组的位置，就能看到我们创创建出来的账户合约的地址

// 还可以加载账户合约，选择账户合约Account，输入账户合约的地址，点击At Address
// 这样就加载出来新的账户合约了，在下方就能看到新的账户合约，可以看到两个变量 bank 和owner
// owner就是传递过去的参数，bank地址就是合约部署这的地址AccountFactory at 0xd91...39138 (memory)
// 在账户合约中，找的是合约部署者的地址，谁部署的Account合约？ AccountFactory合约嘛