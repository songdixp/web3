
// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;


// 质押奖励
// 质押一定的ETH 能在质押有效期内获取一定额度的收益
/*
1. 基础概念：理解智能合约、IERC20接⼝和Solidity语⾔的基本⽤法，如何导⼊IERC20接⼝，以及定义不可变的智能合约状态变量。
2. 状态变量的定义：
- 掌握如何设置staking token（抵押代币）和rewards token（奖励代币）。 
- 学习如何跟踪奖励的持续时间、结束时间、更新时间以及奖励率。
3. 智能合约功能：
- 实现构造函数以初始化合约所有者、抵押代币和奖励代币的地址。
- 编写函数允许⽤⼾抵押代币、提取代币和领取奖励。
- 设定只有合约所有者能够设置奖励持续时间和奖励率的权限。

4. 安全性和管理：
- 使⽤modifier来限制只有所有者才能调⽤某些函数。onlyOwner
- 确保奖励计算和分配的正确性和安全性。

复习要点：
• 理解并能够描述每个状态变量和函数的作⽤及其重要性。
• 复习Solidity的权限控制（如modifiers）和智能合约的安全实践。
• 熟悉智能合约的部署过程及如何与合约交互（抵押、提取、领取奖励等）。

编程作业：
•任务：编写⼀个简单的Solidity智能合约，模拟⽤⼾抵押代币并获得奖励的过程。
•要求：
    a. 创建⼀个名为 SimpleStakingRewards 的智能合约。
    b. 在合约中定义两个状态变量： uint public totalStaked （总抵押量）和 mapping(address => uint) public balances （⽤⼾抵押余额）。
    c. 实现两个函数： stake(uint amount) 和 withdraw(uint amount) 。 stake 函数⽤于增加⽤⼾的抵押余额， withdraw 函数⽤于减少。
    d. 保证只有在⽤⼾账⼾余额充⾜时，才能执⾏ withdraw 函数。
*/ 

import "@openzeppelin/contracts/interfaces/IERC20.sol";


contract StakingRewords{
    // 设置两个token 并且在部署之后不能改变
    IERC20 public immutable stakingToken;
    IERC20 public immutable rewordsToken;

    address public owner;
    uint public duration; //持续时长
    uint public finishedAt;// 结束时间
    uint public updateAt;  //  更新时间
    uint public rewordRate;  //奖励利率，速率
    uint public rewordPerTokenStored; // 每秒奖励多少token (速率 * 时长) / 总质押token， RPT

    mapping(address => uint ) public userRewordPerTokenPaid; // 每个用户的RPT
    mapping(address => uint ) public userRewords; // 每个用户拿到了多少奖励

    uint public totalSupply;  // 一共质押了多少Token
    mapping (address => uint ) public balanceOf; //每个用户质押了多少token

    constructor(address _stakingToken, address _rewordsToken){
        owner = msg.sender;
        stakingToken = IERC20(_stakingToken);
        rewordsToken = IERC20(_rewordsToken);

    }

    modifier onlyOwner(){
        require(msg.sender ==  owner, "not owner");
        _;
    }

    // 编写设置奖励时长的函数
    function setRewordDuration(uint _duration)external onlyOwner{
        // 设置奖励时长需要再结束之后，不希望还在奖励的时候设置时长，要再下一个周期开始前设置
        require(block.timestamp > finishedAt, "reword duration not finished");
        duration = _duration;
    }

    // owner 设置奖励金额的时候 就能通过时长计算出我们的rate
    function notifyRewordAmout(uint _amount)external onlyOwner {}

    // 质押自己的ETH
    function stake(uint _amount)external {}

    // 取出质押的ETH
    function withdraw(uint _amount)external {}

    // 查看奖励金额是杜少
    function earned(address _account) external view  returns(uint amount){}

    // 提取出奖励金
    function withdrawReword(address _account) external {}







}





