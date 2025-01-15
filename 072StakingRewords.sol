
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


// 质押奖励
// 质押一定的ETH 能在质押有效期内获取一定额度的收益
/*
1. 基础概念：理解智能合约、IERC20接⼝和Solidity语⾔的基本⽤法，如何导⼊IERC20接⼝，以及定义不可变的智能合约状态变量。
2. 状态变量的定义：
- 掌握如何设置staking token（抵押代币）和rewards token（奖励代币）。 
- 学习如何跟踪奖励的持续时间、结束时间、更新时间w以及奖励率。
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


contract StakingRewards{
    // 设置两个token 并且在部署之后不能改变
    IERC20 public immutable stakingToken;
    IERC20 public immutable rewardsToken;

    address public owner;
    uint public duration; //持续时长
    uint public finishedAt;// 结束时间
    uint public updateAt;  //  更新时间
    uint public rewardRate;  //奖励利率，速率
    uint public rewardPerTokenStored; // 每秒 每token 奖励多少 (速率 * 时长) / 总质押token， RPT

    mapping(address => uint ) public userRewardPerTokenPaid; // 每个用户的RPT
    mapping(address => uint ) public userRewards; // 每个用户拿到了多少奖励

    uint public totalSupply;  // 一共质押了多少Token
    mapping (address => uint ) public balanceOf; //每个用户质押了多少token

    constructor(address _stakingToken, address _rewardsToken){
        owner = msg.sender;
        stakingToken = IERC20(_stakingToken);
        rewardsToken = IERC20(_rewardsToken);

    }

    modifier onlyOwner(){
        require(msg.sender ==  owner, "not owner");
        _;
    }

    // 追踪 每秒每token奖励金额， 用户每 token花费的奖励金额，且 在质押/取出的时候调用更新数据
    modifier updateReward(address _account){
        rewardPerTokenStored = rewardPerToken();
        updateAt = lastTimeRewardApplicable(); //返回当前时间戳 | 奖励结束的时间

        if (_account !=address(0)){
            // 更新用户的奖励、用户每token的奖励
            userRewards[_account] = earned(_account);
            userRewardPerTokenPaid[_account] = rewardPerTokenStored;
        }
        _;
    }

    // 编写设置奖励时长的函数
    function setRewardDuration(uint _duration)external onlyOwner{
        // 设置奖励时长需要再结束之后，不希望还在奖励的时候设置时长，要再下一个周期开始前设置
        require(block.timestamp > finishedAt, "reward duration not finished");
        duration = _duration;
    }

    // owner 设置奖励金额的时候 就能通过时长计算出我们的rate
    function notifyRewardAmout(uint _amount)external onlyOwner updateReward(address(0)){
        // 没看明白为什么需要更新奖励 ??? updateReward, 既然传入了address0 就只更新 时间和rewardPerTokenStored
        // 奖励还没有开始，或者上一个周期已经结束
        if (block.timestamp > finishedAt) {
            rewardRate = _amount / duration;
        }else{
            // 奖励还在持续中，再发放 ??? 这里为什么是rewardRate * 这里还没有计算出来啊
            uint remainingRewards = rewardRate * (finishedAt -block.timestamp);
            rewardRate = (remainingRewards + _amount) / duration;  // 这里也不明白是什么意思
        }

        require(rewardRate > 0, "reward rate =0");
        require(rewardRate*duration <=rewardsToken.balanceOf(address(this)), "rewward amount > balanceOf");

        // 计算结束时间
        finishedAt = block.timestamp + duration;
        updateAt = block.timestamp;
    }

    // 质押自己的ETH
    function stake(uint _amount)external updateReward(msg.sender){
        require(_amount> 0,"amount <0");
        stakingToken.transferFrom(msg.sender, address(this), _amount);
        balanceOf[msg.sender] += _amount; // 用户质押的金额
        totalSupply += _amount; // 质押总量
    }
    // 状态变量记录完成之后，算法需要追踪  rewardPerTokenStored  userRewardPerTokenPaid
    // 很多地方都需要，需要编写装饰器追踪每一笔 stake和 withdraw对变量的影响，这样就可以重用代码

    // 取出质押的ETH
    function withdraw(uint _amount)external updateReward(msg.sender){
        require(_amount> 0, "amount <0");
        balanceOf[msg.sender] -= _amount;
        totalSupply -= _amount;
        stakingToken.transfer(msg.sender, _amount);

    }
    
    // 时间戳最小值对比,上一次奖励生效的时间
    function lastTimeRewardApplicable () public view returns(uint ){
        return _min(block.timestamp , finishedAt);
    }

    // 用户每token奖励多少
    function rewardPerToken() public view returns (uint){
        // 如果 总供应量是0，直接返回状态变量
        if (totalSupply == 0){
            return rewardPerTokenStored;
        }
            // totalSuply 为除数不能=0,返回RPT
            // 每token 奖励数量 + 奖励速率 * 持续时间
            // 考虑奖励是否已经结束,更新时间相当于奖励开始时间，那么(now , 结束时间) - 开始时间，就是要奖励的时间段
            // 速率 * 时间段，就是这段时间要奖励的金额，再 + 已经设定的奖励的金额 rewardPerTokenStored 整体 除以 所有的token
            // 就得到 每个token要奖励的金额 
        return rewardPerTokenStored + (
                rewardRate * (lastTimeRewardApplicable() - updateAt)
            ) * 1e18 / totalSupply;
        
    }

    // 查看用户奖励金额是多少
    function earned(address _account) public view  returns(uint amount){
        // 用户账户剩余token数量 * 每token奖励金额 + 用户奖励 = 用户的奖励金额
        amount = ( 
            balanceOf[_account] * (rewardPerToken() - userRewardPerTokenPaid[_account])
            ) / 1e18 + userRewards[_account];
    }

    // 获取奖励
    function getReward() external updateReward(msg.sender){
        uint reward = userRewards[msg.sender];
        if (reward > 0){
            userRewards[msg.sender] = 0;
            rewardsToken.transfer(msg.sender, reward);
        }

    }

    // 提取出奖励金
    function withdrawReward(address _account) external {}

    function _min(uint x, uint y) private pure returns (uint) {
        return x <= y ? x : y ;
    }
}


/*
部署测试
1 部署两个ERC20 token 代币合约
2 填写两个ERC20 合约的地址，给StakingRewords 进行部署
3 设置duration ，1000
4 调用 notifyRewardAmout 设置奖励速率，设置前需要确认我们的奖励token已经打到我们的合约里面了
 4.1 在rewardstoken里面进行 mint 给 stakingrewards合约，复制stakingrewards合约地址
 在 rewardstoken 合约中的 mint 方法，地址输入 stakingrewards地址 和 数量amount ： 1000，000000000000000000 1000 +18个0，奖励token就mint给了 Rstakingewards合约了
 4.2 调用 notifyewardsAmount 设置奖励金额 
 
5 质押token
    5.1 切换第二个账户，作为质押账户
    获取质押token， 首先在 stakingtoken合约中mint 质押账户的铸币，复制用户地址，在质押合约中进行 mint，数额一样1000ETH
    5.2 将token，质押到 stakingrewards合约中来
    5.3 在质押ERC20合约中 approve stakingrewards合约
    5.4 质押 stake，在stakingrewards ，成功后检查数据

6 检查奖励数据
    6.1看下质押的数量是否正确，复制质押用户的地址，balanceof
    6.2 查看奖励金额是多少，uint256: amount 133536000000000000000
    6.3 提取奖励 getRewards ，检查earned 方法的金额是否从0开始  1，712，000，000，000，000，000  ？？？ 这里为什么是1712
    6.4 在奖励TOken合约中，检查是否已经收到了奖励，调用balanceOf 地址为质押用户的地址  
        0:uint256: 448544000000000000000
7 提取出来 withdraw 提取质押的token代币
    7.1 调用withdraw，调用balanceof 地址为质押用户地址，发现为0 ，？？？ 提取出来之后，货币去哪里了？是钱包里面吗？


*/ 






