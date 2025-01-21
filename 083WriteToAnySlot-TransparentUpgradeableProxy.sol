

/*
1. 课程⽬标 
    • 学习如何在Solidity智能合约中写⼊任意存储槽 
    • 将实现合约地址和管理员地址存储在新的存储槽中
2. 基础知识 
    • Solidity智能合约的存储结构 
        ◦ 存储是⼀个2^256⼤⼩的数组，每个槽可以存储32字节 
    • keccak256哈希函数 
    • 使⽤结构体和库
3. 实践内容 
    • 移除实现合约和管理员地址的旧存储位置
        ◦ 从Counter B1和Counter B2合约中移除实现合约和管理员地址 
    • 创建新的库和合约来测试存储槽的写⼊
        ◦ 创建⼀个名为 StorageSlot 的库
        ◦ 创建⼀个测试合约 TestSlot
4. 库的实现 
    • 创建结构体 AddressSlot ⽤于存储地址
    • 编写函数getAddressSlot
1
    • 来获取存储槽的指针
        ◦ 使⽤汇编语⾔获取存储指针
        ◦ 函数的可⻅性和状态修饰符调整
5. 测试合约 
    • 定义存储槽常量
        ◦ 使⽤ keccak256 哈希函数⽣成存储槽
    • 编写getter和setter函数 
        ◦ 获取和设置存储槽中的地址
6. 应⽤到代理合约 
    • 重命名代理合约
    • 定义新的存储槽⽤于实现合约和管理员地址
        ◦ 使⽤ keccak256 ⽣成存储槽并减⼀以避免哈希碰撞
    • 编写getter和setter函数 
        ◦ getAdmin 和 getImplementation
        ◦ setAdmin 和 setImplementation
7. 部署和测试 
    • 部署新的代理合约
    • 测试getter和setter函数 
        ◦ 验证实现合约和管理员地址的存储和读取
8. 总结与预告 
    • 复习如何在任意存储槽中存储地址
    • 预告下⼀部分内容：如何分离⽤⼾接⼝和管理员接⼝

    
编程作业 
编写⼀个简单的Solidity合约，包含以下功能： 
1. 定义⼀个存储槽⽤于存储字符串：
◦ 使⽤ keccak256 哈希函数⽣成存储槽
◦ 定义结构体 StringSlot 包含⼀个字符串字段
2. 编写getter和setter函数： 
◦ setStringSlot(string memory newValue) ：将字符串存储到指定槽中
◦ getStringSlot() public view returns (string memory) ：从指定槽中读取字
符串
3. 测试合约：
◦ 部署合约并调⽤setter函数存储字符串 
◦ 调⽤getter函数验证存储的字符串是否正确


*/ 