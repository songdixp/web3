
/*
1. 课程简介
    ⽬标：了解如何在Solidity中使⽤三种不同的⽅法编码数据，以便通过低级函数调⽤其他合约。 
    • ⽅法：编码签名、编码选择器、编码调⽤。

2.编码签名（encode with signature）
    • 使⽤ABI.encodeWithSignature函数。 
    • 输⼊：函数签名（字符串形式）和实际参数。
    • ⽰例：调⽤transfer函数。 
        ◦ 函数签名：)transfer(address,uint256)) 
        ◦ 实际参数：接收地址和⾦额。
    • 优点：简单直接。
    • 缺点：函数签名可以拼写错误，编译时不会报错。

3. 编码选择器（encode with selector） 
    • 使⽤ABI.encodeWithSelector函数。 
    • 输⼊：函数选择器和实际参数。
    • ⽰例：调⽤transfer函数。 
        ◦ 函数选择器：IERC20.transfer.selector 
        ◦ 实际参数：接收地址和⾦额。
    • 优点：避免函数名拼写错误。
    • 缺点：参数类型或数量错误时，编译仍通过。
4. 编码调⽤（encode call） 
    • 使⽤ABI.encodeCall函数。 
    • 输⼊：函数名和实际参数。
    • ⽰例：调⽤transfer函数。 
        ◦ 函数名：IERC20.transfer 
        ◦ 实际参数：接收地址和⾦额。
    • 优点：严格检查函数名、参数类型和数量。
    • 缺点：稍复杂但更安全。
5. 实验：调⽤Token合约 
    • 部署合约：ABI编码合约和Token合约。 
    • 测试：通过调⽤test函数验证所有编码⽅法的结果⼀致性。 
6. ⼩结 
    • 三种编码数据的⽅法各有优劣：
        ◦ encode with signature：可能拼写错误但编译通过。 
        ◦ encode with selector：避免函数名错误，但参数错误仍编译通过。 
        ◦ encode call：严格检查，确保函数名和参数正确。 
编程作业 
任务：实现⼀个合约，使⽤上述三种⽅法编码数据并调⽤⼀个⽰例Token合约的transfer函数。然后验
证返回的数据是否⼀致。
    步骤：
    1. 创建⼀个新的Solidity合约，命名为 DataEncoder 。 
    2. 实现三个函数：
        ◦ encodeWithSignature(address to, uint256 amount)
        ◦ encodeWithSelector(address to, uint256 amount)
        ◦ encodeCall(address to, uint256 amount)
    3. 每个函数使⽤不同的⽅法编码数据并返回编码后的数据。
    4. 部署并调⽤这三个函数，验证返回的数据是否⼀致。



*/ 